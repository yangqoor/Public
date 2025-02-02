from collections import defaultdict

from utils.constants import PAD, UNK, PAD_LABEL


class TokenAlphabet:

    def __init__(self, threshold=3, default_token=None, counter=None, is_label=False, use_crf=False):

        """
        :param threshold: (int) minimum frequency for word
        :param default_token: (dict) predefined tokens in form: token: id
        """
        self.id2token = {}
        self.token2id = defaultdict(int)
        self.threshold = threshold
        self.token2id.default_factory = self.token2id.__len__
        if not is_label:
            self.PAD = default_token.get(PAD, None)
        else:
            if use_crf:
                self.PAD = default_token.get(PAD_LABEL)
            else:
                self.PAD = -100

        if default_token:
            self.token2id.update(default_token)
            self.id2token.update({value: key for key, value in default_token.items()})

        self.counter = counter
        self.add_vector = False
        self.use_crf = use_crf
        self.is_label = is_label

    def id_to_token(self, idx):
        if idx in self.id2token:
            return self.id2token[idx]
        else:
            if self.is_label:
                print('Key error, use PAD %d' % self.PAD)
                return self.id2token[self.PAD]
            else:
                print('Key error, use UNK %d' % UNK)
                return self.id2token[self.token2id[UNK]]

    def token_to_id(self, token):
        if token in self.token2id:
            return self.token2id[token]
        else:
            return self.token2id[UNK]

    def __call__(self, tokens):
        """
        covert toke to id
        toke: str or list[str]
        """
        if isinstance(tokens, str):
            result = self.token_to_id(tokens)
        else:
            result = []
            for token in tokens:
                result.append(self.token2id[token])
        return result

    def build(self,
              token_counter=None,
              dataset=None,
              read_method=None,
              tokenizer=None,
              word_vector=None,
              is_label=None,
              ):
        """
        build vocabulary from dataset or word_counter (not required)
        """
        if token_counter:
            self.counter = token_counter
            for token, frequency in token_counter.items():
                if frequency < self.threshold or token in self.token2id:
                    # ship token within small frequent number
                    continue
                idx = self.token2id[token]
                self.id2token[idx] = token
        if dataset:
            if read_method:
                all_sentence = read_method(self.dataset)
            else:
                with open(self.dataset, 'r', encoding='utf-8') as f:
                    all_sentence = f.readlines()
            for sentence in all_sentence:
                token_sentence = tokenizer(sentence)
                for token in token_sentence:
                    self.counter[token] += 1
                for token, frequency in self.counter:
                    if frequency < self.threshold and token in self.token2id:
                        # ship token within small frequent number
                        continue
                    idx = self.token2id[token]
                    self.id2token[idx] = token

        if word_vector:
            for word in word_vector.key():
                if word not in self.token2id:
                    idx = self.token2id[word]
                    self.id2token[idx] = word
            self.add_vector = True
        if self.is_label and not self.use_crf:
            self.id2token[-100] = PAD
            self.token2id[PAD] = -100


    def add(self, words):
        """
        add more words to Vocabulary
        :param words: iterable
        :return: None
        """
        for word in words:
            if word not in self.token2id:
                idx = self.token2id[word]
                self.id2token[idx] = word

    def __len__(self):
        return len(self.token2id)

    def __iter__(self):
        return iter(self.token2id)
