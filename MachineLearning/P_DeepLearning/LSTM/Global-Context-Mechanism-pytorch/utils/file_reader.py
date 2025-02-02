from collections import Counter


def ner_reader(dataset_path):
    """
    read all words in dataset
    :param dataset_path: (str)
    :return: file generator
    """
    with open(dataset_path, 'r', encoding='utf-8') as f:
        sentence = []
        labels = []
        for line in f:
            if line != '\n' and line != '\t\n':
                if '\t' in line:
                    pairs = line.split('\t')
                else:
                    pairs = line.split()
                sentence.append(pairs[0])
                labels.append(pairs[-1].strip())
            else:
                if sentence:
                    yield sentence, labels
                sentence, labels = [], []
        if sentence:
            yield sentence, labels


def pos_reader(dataset_path):
    with open(dataset_path, 'r', encoding='utf-8') as f:
        sentence = []
        labels = []
        for line in f:
            if line != '\n' and line != '\t\n':
                if '\t' in line:
                    pairs = line.split('\t')
                else:
                    pairs = line.split()
                sentence.append(pairs[0])
                labels.append(pairs[1].strip())
            else:
                if sentence:
                    yield sentence, labels
                sentence, labels = [], []
        if sentence:
            yield sentence, labels


def ner_reader_cn(dataset_path):
    with open(dataset_path, 'r', encoding='utf-8') as f:
        sentence = []
        labels = []
        for line in f:
            if line != '\n' and line != '\t\n':
                pairs = line.strip()
                sentence.append(pairs[0])
                labels.append(pairs[-1])
            else:
                if sentence:
                    yield sentence, labels
                sentence, labels = [], []
        if sentence:
            yield sentence, labels


if __name__ == "__main__":
    dataset = '../Dataset/Ner/weibo/train.txt'



    # file_name = 'valid.txt'
    # number_sentence = 0
    # with open(file_name, 'r', encoding='utf-8') as f:
    #     all_sentence, all_labels = [], []
    #     sentence, labels = [], []
    #     for line in f:
    #         if line != '\n':
    #             pairs = line.strip().split()
    #             sentence.append(pairs[0])
    #             labels.append(pairs[-1])
    #         else:
    #             all_sentence.append(sentence)
    #             all_labels.append(labels)
    #             sentence, labels = [], []
    #     if sentence:
    #         all_sentence.append(sentence)
    #         all_labels.append(labels)
    # idx = 0
    # for sentence_, labels_ in ner_reader(file_name):
    #     assert sentence_ == all_sentence[idx]
    #     assert labels_ == all_labels[idx]
    #     assert len(sentence_) == len(labels_)
    #     idx += 1

