"""
tokenizer method for light mode
modify date: 2022.04.02
"""
import sys
import copy
import pickle
import string
from typing import Callable, List, Iterable

from utils.constants import UNK

sys.setrecursionlimit(1000)


class BaseTokenizer:
    def __init__(self, tokenizer: Callable = None, word_alphabet: dict = None):
        self.tokenizer = tokenizer
        self.word_alphabet = word_alphabet

    def encode(self, sentence: str, is_split_word=False) -> List:
        """
        tokenizer, convert sentences to ids for original sentence
        :param sentence: [str, List[str]]
        :param is_split_word: Bool
        :return: List[int], List[List[int]]
        """
        if sentence:
            if isinstance(sentence, str):
                tokenized_sentence = self.split(sentence)
                id_sentence = []
                for token in tokenized_sentence:
                    id_sentence.append(self.add_alphabet(token))
                return id_sentence
            else:
                # List of sentences
                for item in sentence:
                    pass
        else:
            raise TypeError("Input sentence don't have content")

    def split(self, sentence: str) -> List:
        if self.tokenizer:
            return self.tokenizer(sentence)
        return list(sentence)

    def add_alphabet(self, alphabet):
        self.word_alphabet = alphabet


def gen_word_feature(sentences, max_sentence_length):
    batch_word_feature = []
    padded_word_features = [0] * 4
    for sent in sentences:
        sent_word_features = []
        for word in sent:
            word_features = [0.] * 4
            if word.isupper():
                word_features[0] = 1.
            elif word.capitalize():
                word_features[1] = 1.
            elif word.islower():
                word_features[2] = 1.
            else:
                for char in word:
                    if char.issupper():
                        word_features[3] = 1
            sent_word_features.append(word_features)
        padded_num = max_sentence_length - len(sent_word_features)
        for i in range(padded_num):
            sent_word_features.append(padded_word_features)
        batch_word_feature.append(sent_word_features)
    return batch_word_feature


def map_to_ids(alphabet, iterable):
    """
    convert token to corresponding ids by alphabet
    """
    ids = []
    for item in iterable:
        ids.append(alphabet(item.lower()))
    return ids


class NERTokenizer(BaseTokenizer):

    def __init__(self,
                 tokenizer: Callable = None,
                 word_alphabet: dict = None,
                 label_alphabet: dict = None,
                 char_alphabet: dict = None,
                 extra_word_feature=True,
                 extra_char_feature=True,
                 local_path='tokenizer.bin'):
        super(NERTokenizer, self).__init__(tokenizer, word_alphabet)
        self.label_alphabet = label_alphabet
        self.char_alphabet = char_alphabet
        self.extra_word_feature = extra_word_feature
        self.extra_char_feature = extra_char_feature

    def encode(self, sentences: list, labels: list, chars: list = None, is_split_word=True) -> List:
        """
        convert batch of sentences or a sentence to IDs
        """
        sentence_ids, label_ids, input_masks = [], [], []
        label_ids_original = []
        if sentences:
            if not is_split_word:
                sentences = [self.split(sent) for sent in sentences if sent]
            max_sent_length = max([len(sent) for sent in sentences])
            if self.extra_word_feature:
                batch_word_feature = gen_word_feature(sentences, max_sent_length)
            if chars:
                char_ids, char_extra_feature = self.encode_char(chars, max_sent_length)
            for sent, label in zip(sentences, labels):
                # sentence_id = list(map(self.word_alphabet, [word.lower() for word in sent]))
                sentence_id = map_to_ids(self.word_alphabet, sent)
                label_id = list(map(self.label_alphabet, label))
                pad_num = max_sent_length - len(sentence_id)
                masks = [1] * len(sentence_id)
                label_ids_original.append(copy.copy(label_id))
                if pad_num > 0:
                    sentence_id.extend([self.word_alphabet.PAD] * pad_num)
                    label_id.extend([self.label_alphabet.PAD] * pad_num)
                    masks.extend([0] * pad_num)
                sentence_ids.append(sentence_id)
                label_ids.append(label_id)
                input_masks.append(masks)

        else:
            raise {"input sentence is None"}
        result = {
            'label_ids_original': label_ids_original,
            'sentence_ids': sentence_ids,
            'label_ids': label_ids,
            'extra_word_feature': batch_word_feature,
            'masks': input_masks
        }
        if chars:
            result.update({'char_ids': char_ids,
                           'extra_char_feature': char_extra_feature})

        return result

    def encode_char(self, batch_chars, max_sent_length=None, max_word_length=None):
        """
        sent_chars: three dimensions[batch, sentence_length, word_length]
        return: padded char features
        """
        if not max_word_length:
            max_word_length = max([max(map(len, sent_chars)) for sent_chars in batch_chars])
        word_padded = [self.char_alphabet.PAD] * max_word_length
        batch_char_ids = []
        batch_extra_feature = []
        for sent_chars in batch_chars:
            sent_char_ids = []
            sent_extra_feature = []
            for word_chars in sent_chars:
                word_extra_feature = [0.] * 4
                # word_char_ids = list(map(self.char_alphabet, [char.lower() for char in word_chars]))
                word_char_ids = map_to_ids(self.char_alphabet, word_chars)
                char_padded_num = max_word_length - len(word_char_ids)
                for char in word_chars:
                    if char.isupper():
                        word_extra_feature[0] = 1.
                    elif char.isdigit():
                        word_extra_feature[1] = 1.
                    elif char.islower():
                        word_extra_feature[2] = 1.
                    elif char in string.punctuation:
                        word_extra_feature[3] = 1.
                sent_extra_feature.append(word_extra_feature)
                if char_padded_num > 0:
                    word_char_ids.extend([self.char_alphabet.PAD] * char_padded_num)
                sent_char_ids.append(word_char_ids)
            word_padded_num = max_sent_length - len(sent_char_ids)
            if word_padded_num > 0:
                for i in range(word_padded_num):
                    sent_char_ids.append(word_padded)
                    sent_extra_feature.append([0] * 4)
            batch_char_ids.append(sent_char_ids)
            batch_extra_feature.append(sent_extra_feature)
        return batch_char_ids, batch_extra_feature

    def add_alphabet(self, word_alphabet, label_alphabet, char_alphabet):
        self.word_alphabet = word_alphabet
        self.label_alphabet = label_alphabet
        self.char_alphabet = char_alphabet


def tokenizer_save(object_, path):
    pickle.dump(object_.__dict__, open(path, 'wb'))


def tokenizer_load(path):
    return pickle.load(open(path, 'rb'))


