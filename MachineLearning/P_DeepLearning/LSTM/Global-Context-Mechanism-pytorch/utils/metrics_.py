import collections
from collections import Counter
from typing import Iterable, List

import numpy as np
import torch



class SEQMetric:
    def __init__(self, id2token, use_crf=False):
        self.id2token = id2token
        self.gold = []
        self.pred = []
        self.right = []
        self.use_crf = use_crf


class NERMetric(SEQMetric):
    def __init__(self, id2token, use_crf=False):
        super(NERMetric, self).__init__(id2token, use_crf)

    def get_entity(self, labels, is_gold=True, gold=None, ignore_index=-100, device='cpu'):
        """
        prediction: numpy[batch_size, max_len] or tensor[batch_size, max_len]
        """
        chunks = []
        chunk = [-1, -1, -1]
        if device != 'cpu':
            labels = np.array(labels.cpu().reshape(-1, ))
        else:
            if not isinstance(labels, List):
                labels = labels.detach().cpu().numpy().reshape(-1, )
        # length = labels.shape[0]
        if is_gold:
            if not self.use_crf:
                indices = labels != -100
                labels = labels[indices]
                labels = list(map(lambda x: self.id2token.id_to_token(x), labels))
            else:
                all_labels = []
                for idx, i in enumerate(labels):
                    all_labels.extend(list(map(lambda x: self.id2token.id_to_token(x), i)))
                labels = all_labels
        else:
            if not self.use_crf:
                gold = np.array(gold.cpu().reshape(-1, ))
                indices = gold != ignore_index
                labels = labels[indices]
                labels = list(map(lambda x: self.id2token.id_to_token(x), labels))
            else:
                all_labels = []
                for idx, i in enumerate(labels):
                    all_labels.extend(list(map(lambda x: self.id2token.id_to_token(x), i)))
                labels = all_labels


        length = len(labels)
        for idx, value in enumerate(labels):
            if value.startswith('B-'):
                if chunk[0] != -1:
                    chunks.append(chunk)
                category = value.split('-')[-1]
                chunk = [category, idx, idx]

                if idx == length - 1:
                    chunks.append(chunk)
            elif value.startswith('I-'):
                category = value.split('-')[-1]
                pre_category = chunk[0]
                if category == pre_category:
                    chunk[-1] = idx
                else:
                    if isinstance(pre_category, str):
                        chunks.append(chunk)
                        chunk = [-1, -1, -1]
                if idx == length - 1:
                    chunks.append(chunk)

            else:
                if chunk[1] != -1:
                    chunks.append(chunk)
                    chunk = [-1, -1, -1]

        return chunks

    def calculate_f1(self, is_fined_grain=True):
        """
        :param is_fined_grain: denoted whether calculate fined grain f1 value
        :return:
        """
        names = ['precision', 'recall', 'f1']
        pred_num, right_num, gold_num = map(len, (self.pred, self.right, self.gold))
        # precision = right_num / gold_num if right_num else 0
        # recall = right_num / gold_num if gold_num else 0
        precision, recall, f1_value = f1_(pred_num, right_num, gold_num)
        f1 = dict(zip(names, [precision, recall, f1_value]))
        fined_grain_f1 = {}
        if is_fined_grain:
            pred_counter = Counter([i[0] for i in self.pred])
            right_counter = Counter(i[0] for i in self.right)
            gold_counter = Counter(i[0] for i in self.gold)
            for category, gold_num in gold_counter.items():
                pred_num = pred_counter.get(category, 0)
                right_num = right_counter.get(category, 0)
                precision, recall, f1_value = f1_(pred_num, right_num, gold_num)
                fined_grain_f1[category] = dict(zip(names, [precision, recall, f1_value]))
        return f1, fined_grain_f1

    def __call__(self, prediction: Iterable, gold: torch.Tensor, ignore_index=-100):
        """

        :param prediction:
        :param gold: tensor[batch_size, max_len] or list[batch_size, max_len]
        :return:
        """
        pred_entities = self.get_entity(prediction, is_gold=False, gold=gold, ignore_index=ignore_index)
        gold_entities = self.get_entity(gold, ignore_index=ignore_index)
        self.pred.extend(pred_entities)
        self.gold.extend(gold_entities)
        self.right.extend([items for items in pred_entities if items in gold_entities])


class POSMetric(SEQMetric):
    def __init__(self, id2token, use_crf=False):
        super(POSMetric, self).__init__(id2token, use_crf=use_crf)

    def get_entity(self, labels, is_gold=True, gold=None, ignore_index=-100, device='cpu'):
        """
        prediction: numpy[batch_size, max_len] or tensor[batch_size, max_len]
        """
        if device != 'cpu':
            labels = np.array(labels.cpu().reshape(-1, ))
        else:
            if not isinstance(labels, List):
                labels = labels.detach().cpu().numpy().reshape(-1, )
        # length = labels.shape[0]
        if is_gold:
            if not self.use_crf:
                indices = labels != -100
                labels = labels[indices]
                labels = list(map(lambda x: self.id2token.id_to_token(x), labels))
            else:
                all_labels = []
                for idx, i in enumerate(labels):
                    all_labels.extend(list(map(lambda x: self.id2token.id_to_token(x), i)))
                labels = all_labels
        else:
            if not self.use_crf:
                gold = np.array(gold.cpu().reshape(-1, ))
                indices = gold != ignore_index
                labels = labels[indices]
                labels = list(map(lambda x: self.id2token.id_to_token(x), labels))
            else:
                all_labels = []
                for idx, i in enumerate(labels):
                    all_labels.extend(list(map(lambda x: self.id2token.id_to_token(x), i)))
                labels = all_labels

        return labels

    def calculate_f1(self, is_fined_grain=True):
        """
        :param is_fined_grain: denoted whether calculate fined grain f1 value
        :return:
        """
        names = ['precision', 'recall', 'f1']
        pred_num, right_num, gold_num = map(len, (self.pred, self.right, self.gold))
        # precision = right_num / gold_num if right_num else 0
        # recall = right_num / gold_num if gold_num else 0
        precision, recall, f1_value = f1_(pred_num, right_num, gold_num)
        f1 = dict(zip(names, [precision, recall, f1_value]))
        fined_grain_f1 = {}
        if is_fined_grain:
            pred_counter = Counter(self.pred)
            right_counter = Counter(self.right)
            gold_counter = Counter(self.gold)
            for category, gold_num in gold_counter.items():
                pred_num = pred_counter.get(category, 0)
                right_num = right_counter.get(category, 0)
                precision, recall, f1_value = f1_(pred_num, right_num, gold_num)
                fined_grain_f1[category] = dict(zip(names, [precision, recall, f1_value]))
        return f1, fined_grain_f1

    def __call__(self, prediction: Iterable, gold: torch.Tensor, ignore_index=-100):
        """

        :param prediction:
        :param gold: tensor[batch_size, max_len] or list[batch_size, max_len]
        :return:
        """
        pred_entities = self.get_entity(prediction, is_gold=False, gold=gold, ignore_index=ignore_index)
        gold_entities = self.get_entity(gold, ignore_index=ignore_index)
        right = []
        if len(pred_entities) == len(gold_entities):
            for pred, gold in zip(pred_entities, gold_entities):
                if pred == gold:
                    right.append(pred)
        else:
            raise ValueError('pred length: %d do not match the length of gold %d' % (len(pred_entities), len(gold_entities)))
        self.right.extend(right)
        self.pred.extend(pred_entities)
        self.gold.extend(gold_entities)


class SegMetric(NERMetric):
    def __init__(self, id2token=None):
        super(SegMetric, self).__init__(id2token)

    def __call__(self, prediction: List[tuple], gold: List[tuple]) -> None:
        self.pred.extend(prediction)
        self.gold.extend(gold)
        self.right.extend([item for item in prediction if item in gold])


def f1_(pred_num, right_num, gold_num):
    precision = right_num / pred_num if pred_num else 0
    recall = right_num / gold_num if gold_num else 0
    f1_value = (2 * precision * recall) / (precision + recall) if precision and recall else 0.
    return precision, recall, f1_value

# pred_ = [('你', 1, 2)]
# gold_ = [('你', 1, 2), ('我', 1, 2)]
# metric = SegMetric()
# metric(pred_, gold_)
# f1, fined_grain = metric.calculate_f1()
# print(f1, fined_grain)









