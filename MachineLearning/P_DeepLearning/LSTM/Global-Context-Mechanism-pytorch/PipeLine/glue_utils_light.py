"""
utils for light model
"""
import numpy as np
import torch
from numpy.random import default_rng
# from flair.data import Sentence

import json


def read_vector(word_vector_source, skip_head=False, vector_dim=100) -> dict:
    """

    :param word_vector_source: path of word2vector file
    :param skip_head: (bool)
    :param vector_dim: dimension of vector
    :return: (dict), key word, value vector
    """
    word_vector = {}
    with open(word_vector_source, 'r', encoding='utf-8') as f:
        if skip_head:
            f.readline()
        line = f.readline()
        assert len(line.split()) == vector_dim + 1
        while line:
            word_vector_list = line.split()
            word, vector = word_vector_list[0], word_vector_list[1:]
            if len(vector) == vector_dim:
                vector = [float(num) for num in vector]
                word_vector[word] = vector
            line = f.readline()
        return word_vector


def build_matrix(token_alphabet, word_vector, word_dim=100) -> np.array:
    random_generator = default_rng()
    total_word = len(token_alphabet)
    out_vocabulary = 0
    # vector_matrix = random_generator.standard_normal((total_word, word_dim))
    vector_matrix = np.zeros((total_word, word_dim))
    for word in token_alphabet:
        if word in word_vector or word.lower() in word_vector:
            idx = token_alphabet.token2id[word]
            vector_matrix[idx, :] = word_vector[word]
        else:
            out_vocabulary += 1
    print(f'out of vocabulary number: {out_vocabulary}/{len(token_alphabet)}')
    return torch.tensor(vector_matrix, dtype=torch.float)


def json_reader(file_path, x_name='text', y_name='entities') -> tuple:
    """
    read file from file path and generate (text, label)
    :param file_path: str
    :param x_name: str
    :param y_name: str
    :return: (tuple(str, list), tuple(doc_id, sent_id, name))  : text, label, extra_info
    """
    data = json.load(open(file_path, 'r', encoding='utf-8'))
    for doc_id, doc in enumerate(data):
        description = doc['category'][0]
        for sent_id, text in enumerate(doc[x_name]):
            sent_entity = doc[y_name][sent_id]
            label = ['O'] * len(text)
            for entity in sent_entity:
                start = entity[0]
                end = entity[1]
                value = entity[-1]
                entity_ = entity[2]
                label[start] = 'B-' + entity_
                for index in range(start+1, end+1):
                    label[index] = 'I-' + entity_
                yield (text, label), (doc_id, sent_id, description)


def collate_flair_seq(batch, flair_method=None):
    batchify_input = {}
    sentences = []
    labels = []
    lengths = []

    for text, label in batch:
        sentences.append(Sentence(text))
        labels.append(label)
        lengths.append(len(text))
    max_length = max(lengths)
    batch_size = len(lengths)
    input_tensor = torch.zeros((batch_size, max_length, ))


def collate_seq_light(batch, tokenizer=None):
    pass


if __name__ == "__main__":
    file_path_ = '../Dataset/NER/医疗信息抽取/检查.json'

    for (text_, label_), (doc_id_, sent_id_, description_) in json_reader(file_path_):
        print(doc_id_, sent_id_, text_, description_)
        print(label_)

