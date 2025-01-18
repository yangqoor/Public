# --*-- coding: utf-8 --*--
"""
hugging face bert utils to work with glue tasks
"""
import os
from typing import Optional

import torch
from torch.utils.data import Dataset


class InputExample:
    """
    input structures for transformer models
    """

    def __init__(self, guid: int, text_a: str, text_b: Optional[str] = None,
                 label: Optional[str] = None):
        self.guid = guid
        self.text_a = text_a
        self.text_b = text_b
        self.label = label

    def __str__(self):
        if self.text_b:
            return "text_a: {} \t text_b: {}".format(self.text_a, self.text_b)
        return "text: {} \t".format(self.text_a)


class BaseExamples:
    """
    base class to construct input example for transformer models
    """

    def __init__(self, base_path=None, read_method=None):
        self.read_method = read_method
        self.base_dir = base_path
        self.train_examples = []
        self.dev_examples = []
        self.test_examples = []

    def get_train_examples(self, data_path) -> list:
        raise NotImplementedError

    def get_dev_examples(self, data_path) -> list:
        raise NotImplementedError

    def get_test_examples(self, data_path) -> list:
        raise NotImplementedError

    def get_labels(self):
        raise NotImplementedError

    def construct_examples(self, data_path):
        raise NotImplementedError


class SeqExamples(BaseExamples):
    def __init__(self, base_path=None, read_method=None):
        super(SeqExamples, self).__init__(base_path, read_method)

    def get_train_examples(self, data_path=None) -> list:
        if data_path:
            source = data_path
        else:
            source = os.path.join(self.base_dir, 'train')
        self.train_examples = self.construct_examples(source)
        return self.train_examples

    def get_dev_examples(self, data_path=None) -> list:
        if data_path:
            source = data_path
        else:
            source = os.path.join(self.base_dir, 'valid')
        self.dev_examples = self.construct_examples(source)
        return self.dev_examples

    def get_test_examples(self, data_path=None) -> list:
        if data_path:
            source = data_path
        else:
            source = os.path.join(self.base_dir, 'test')
        self.test_examples = self.construct_examples(source)
        return self.test_examples

    def get_labels(self):
        label_list = []
        for example in self.train_examples:
            for label in example.label:
                if label not in label_list:
                    label_list.append(label)
        return label_list

    def construct_examples(self, data_path):
        examples = []
        # read_method return data in (sentence[list], label[list) format
        data_generator = self.read_method(data_path)
        guid = 0
        for sentence, labels in data_generator:
            examples.append(InputExample(guid=guid, text_a=sentence, label=labels))

        return examples


def convert_examples_to_records(examples: list, tokenizer, is_split_into_words=True) -> list:
    records = []
    for example in examples:
        record = tokenizer(example.text_a, is_split_into_words=is_split_into_words)
        label_ids = []
        pre_word_id = None
        for word_id in record.word_ids():
            if word_id is None:
                label_ids.append(-100)
            elif word_id != pre_word_id:
                label_ids.append(-100)
            else:
                label_ids.append(-100)
        record['labels'] = label_ids
        records.append(record)
    return records


class SeqDataset(Dataset):
    def __init__(self, dataset_path, read_method):
        self.source = dataset_path
        self.reader = read_method
        self.examples = []
        self.__construct_examples()

    def __len__(self):
        return len(self.examples)

    def __getitem__(self, item):
        return self.examples[item]

    def get_label(self):
        labels = []
        for example in self.examples:
            for label in example.label:
                if label not in labels:
                    labels.append(label)
        return labels

    def __construct_examples(self):
        data_generator = self.reader(self.source)
        guid = 0
        for sentence, labels in data_generator:
            self.examples.append(InputExample(guid=guid, text_a=sentence, label=labels))


class CollateFnSeq:
    def __init__(self, tokenizer=None, is_split_into_words=True, seq_task=True, label2idx=None, idx2label=None):
        self.tokenizer = tokenizer
        self.is_split_into_words = is_split_into_words
        self.seq_task = seq_task
        self.label2idx = label2idx
        self.idx2label = idx2label
        self.batch_texts = []
        self.batch_labels = []

    def __call__(self, batch):
        texts = []
        labels = []
        padded_labels = []

        for example in batch:
            texts.append(example.text_a)
            labels.append(example.label)
        self.batch_labels = labels
        self.batch_texts = texts
        batchify_input = self.tokenizer(texts, padding='longest', is_split_into_words=self.is_split_into_words,
                                        truncation=True, return_tensors='pt')
        if self.seq_task:
            for idx, label in enumerate(labels):
                label_id = []
                pre_word = None
                for word_idx in batchify_input.word_ids(batch_index=idx):
                    if word_idx is None:
                        label_id.append(-100)
                    elif word_idx != pre_word:
                        label_id.append(self.label2idx[label[word_idx]])
                        pre_word = word_idx
                    else:
                        label_id.append(-100)
                padded_labels.append(label_id)
            batchify_input['labels'] = torch.tensor(padded_labels)
        else:
            batchify_input['labels'] = torch.tensor(labels)
        return batchify_input


def collate_fn_seq(batch, tokenizer, label2id=None, is_split_into_words=True):
    texts = []
    labels = []
    padded_labels = []
    for example in batch:
        texts.append(example.text_a)
        labels.append(example.label)
    batchify_input = tokenizer(texts, padding='longest', is_split_into_words=is_split_into_words,
                               truncation=True, return_tensors='pt')
    for idx, label in labels:
        label_id = []
        pre_word = None
        for word_idx in batchify_input.word_ids(batch_index=idx):
            if word_idx is None:
                label_id.append(-100)
            elif word_idx != pre_word:
                label_id.append(label[word_idx])
                pre_word = word_idx
            else:
                label_id.append(-100)
        padded_labels.append(label_id)
    batchify_input['labels'] = torch.tensor(padded_labels)
    return batchify_input








