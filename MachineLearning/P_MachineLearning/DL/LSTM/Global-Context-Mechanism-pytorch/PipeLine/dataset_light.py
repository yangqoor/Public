"""

"""
import abc
import torch
from typing import List, Optional
from torch.utils.data import Dataset

from utils.constants import PAD


class InputExample:
    """
    structure input data
    """

    def __init__(self, guid: int, text_a: str, text_b: Optional[str] = None, label: int = None):
        """

        :param guid: unique id for each input example
        :param text_a:
        :param text_b: Optional required when do text similarity tasks
        :param label: label for each input example
        """
        self.guid = guid
        self.text_a = text_a
        self.text_b = text_b
        self.label = label

    def __repr__(self):
        if self.text_b:
            print(f"text_a={self.text_a} \t text_b={self.text_b}\tlabel={self.label}")
        else:
            print(f"text={self.text_a} \t label={self.label}")


class BaseDataset(Dataset):
    def __init__(self):

        self.data = []

    def __len__(self):
        return len(self.data)

    def __getitem__(self, item):
        return self.data[item]

    @abc.abstractmethod
    def read(self):
        pass


class SADataset(BaseDataset):
    def __init__(self, dataset_path, tokenizer=None):
        super(SADataset).__init__(dataset_path, tokenizer)

    def read(self):
        all_data = []
        with open(self.dataset_path, 'r', encoding='utf-8') as f:
            line = f.readline()
            while line:
                per_data = {}
                words = []
                labels = []
                line_list = line.strip().split('####')
                sentence, sequence = line_list[0], line_list[1]
                per_data['original_sentence'] = sentence
                for item in sequence:
                    tmp = item.split('=')
                    word, label = tmp[0], tmp[1]
                    words.append(word)
                    labels.append(label)
                per_data['sentence'] = words
                per_data['labels'] = labels
                all_data.append(words)
                all_data.append(labels)
                line = f.readline()
        return all_data


class NERDataset(BaseDataset):
    def __init__(self,
                 dataset_path=None,
                 read_method=None,
                 char_feature=True,
                 tokenizer=None,
                 do_tokenization=False):
        super(NERDataset, self).__init__()
        self.dataset_path = dataset_path
        self.char_feature = char_feature
        self.tokenizer = tokenizer
        self.do_tokenization = do_tokenization
        self.data = self.read(read_method)

    def read(self, read_method=None):
        all_data = []
        file_generator = read_method(self.dataset_path)
        for sentence, labels in file_generator:
            if self.do_tokenization:
                sentence_tokens = self.tokenizer(sentence)
            else:
                sentence_tokens = sentence
            origin_sentence_length = len(sentence_tokens)
            train_item = {'sentence': sentence_tokens,
                          'labels': labels,
                          'sentence_length': origin_sentence_length}
            if self.char_feature:
                sentence_chars = []
                words_length_list = []
                for idx, word in enumerate(sentence_tokens):
                    word_chars = []
                    for char in word:
                        word_chars.append(char)
                    word_len = len(word_chars)
                    words_length_list.append(word_len)
                    sentence_chars.append(word_chars)
                train_item['chars'] = sentence_chars
                train_item['word_length'] = words_length_list
            all_data.append(train_item)
        return all_data


class CollateFn:
    def __init__(self, tokenizer):
        self.tokenizer = tokenizer

    def __call__(self, ):
        pass

