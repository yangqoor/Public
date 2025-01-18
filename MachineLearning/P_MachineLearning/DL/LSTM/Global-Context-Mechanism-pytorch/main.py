# --*-- coding: utf-8 --*--
# last updated: 2024.04.14
import os

os.environ['CUBLAS_WORKSPACE_CONFIG'] = ':16:8'
import argparse
import random
from functools import partial
from collections import Counter, defaultdict

import pickle
import logging
import torch
import tqdm
import torch.optim as optim
from torch.optim.lr_scheduler import StepLR
import numpy as np
from torch.utils.data import DataLoader, TensorDataset
from transformers import AutoTokenizer, AutoModel, AutoConfig
from transformers import get_linear_schedule_with_warmup

from utils.metrics import NERMetric, POSMetric
from utils.constants import default_token, default_token_label, default_token_label_crf
from utils.tools import log_wrapper
from utils.file_reader import ner_reader, pos_reader
from PipeLine.glue_utils_light import read_vector, build_matrix
from PipeLine.tokenizer import NERTokenizer
from PipeLine.dataset_light import NERDataset
from PipeLine.vocabulary import TokenAlphabet
from PipeLine.glue_utils_transformer import SeqDataset, CollateFnSeq
from model.transformer_base import BertForSeqTask
from model.rnn import RNNNet
from model.S_LSTM import SLSTMCell

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

READER = {
    'absa': ner_reader,
    'NER': ner_reader,
    'pos': pos_reader
}

METRIC = {
    'absa': NERMetric,
    'NER': NERMetric,
    'pos': POSMetric
}

MODEL = {'lstm': RNNNet,
         's-lstm': SLSTMCell}


def build_counter(dataset_path, reader_method=None, use_char=False,
                  tokenizer=None, tokenization=False) -> tuple:
    """
    build word_counter and char_counter for dataset
    :return:
    """
    # word_counter = defaultdict(int)
    # char_counter = defaultdict(int)
    # label_counter = defaultdict(int)
    word_counter = Counter()
    char_counter = Counter()
    label_counter = Counter()
    file_generator = reader_method(dataset_path)
    if reader_method:
        for sentence, label in file_generator:
            if tokenization:
                sentence_tokens = tokenizer(sentence)
                word_counter.update([word.lower() for word in sentence_tokens])
                if use_char:
                    for word_token in sentence_tokens:
                        char_counter.update(word_token)
            else:
                word_counter.update([word.lower() for word in sentence])
                if use_char:
                    for word in sentence:
                        char_counter.update([char.lower() for char in word])
            label_counter.update(label)

    return word_counter, char_counter, label_counter


def init_alphabet(word_counter, char_counter=None, label_counter=None, use_crf=False):
    label_token_default = default_token_label_crf if use_crf else default_token_label
    word_alphabet, char_alphabet, label_alphabet = TokenAlphabet(default_token=default_token), \
        TokenAlphabet(default_token=default_token), \
        TokenAlphabet(default_token=label_token_default, is_label=True, use_crf=use_crf)
    word_alphabet.build(word_counter)
    char_alphabet.build(char_counter)
    label_alphabet.build(label_counter, is_label=True)
    return word_alphabet, char_alphabet, label_alphabet


def init_args():
    argument = argparse.ArgumentParser()
    # basic configuration
    argument.add_argument('--log_dir', type=str, default='log')
    argument.add_argument('--cache_dir', type=str, help='pretrained model cache directory',
                          default='cache/')
    argument.add_argument('--result_dir', type=str, default='results')
    argument.add_argument('--dataset_dir', type=str, default='Dataset')
    argument.add_argument('--model_dir', type=str, default='saved_model')
    argument.add_argument('--tmp_dir', type=str, default='tmp')
    argument.add_argument('--device', type=str, default='cuda')
    argument.add_argument('--fix_pretrained', type=str, default='False')
    argument.add_argument('--best_model', type=str,
                          default='/home/cs.aau.dk/ut65zx/saved_model-tagger-context/bert-base-chinese_13.pth')
    # tasks specified configuration
    argument.add_argument('--task_type', type=str, default='NER')
    # argument.add_argument('--task_type', type=str, default='pos')
    argument.add_argument('--mode', type=str, choices=['light', 'pretrained'], default='pretrained')
    # argument.add_argument('--dataset_name', type=str, default='Ontonotes')
    argument.add_argument('--dataset_name', type=str, default='Conll2003')
    # argument.add_argument('--dataset_name', type=str, default='weibo')
    argument.add_argument('--train', type=str, default='True')
    # common configuration for models
    argument.add_argument('--use_crf', type=str, default='False')
    argument.add_argument('--use_context', type=str, default='True')
    argument.add_argument('--context_mechanism', type=str, choices=['global', 'self-attention'], default='global')
    argument.add_argument('--seed', type=int, default=40)
    argument.add_argument('--num_epoch', type=int, default=300)
    argument.add_argument('--batch_size', type=int, default=16)
    argument.add_argument('--learning_rate', type=float, default=5e-5)
    argument.add_argument('--learning_rate_tagger', type=float, default=1e-3)
    argument.add_argument('--learning_rate_context', type=float, default=5e-2)
    argument.add_argument('--learning_rate_classifier', type=float, default=1e-4)
    argument.add_argument('--momentum', type=float, default=0.9)
    argument.add_argument('--dropout_rate', type=float, default=0.1)
    argument.add_argument('--grad_norm', type=float, default=5.0, help="argument for cutting gradient")
    argument.add_argument('--weight_decay', type=float, default=0.0)
    argument.add_argument('--adam_eps', type=float, default=1e-08)
    argument.add_argument('--warmup_step', type=int, default=5, help='how many steps to execute warmup strategy')
    argument.add_argument('--warmup_strategy', type=str, choices=['None', 'Linear', 'Cosine', 'Constant'],
                          default='None')
    argument.add_argument('--no_improve', type=int, default=5, help='how many steps no improvement to stop training')
    # configuration for light models
    argument.add_argument('--use_char', type=str, default='False')
    argument.add_argument('--word_vector', type=str, default=r'WordVector/glove.6B.100d.txt')
    # argument.add_argument('--word_vector', type=str, default=r'WordVector/glove.twitter.27B.200d.txt')
    # argument.add_argument('--word_vector', type=str,
    #                       default=r'/home/WordVector/glove.twitter.27B.200d.txt')
    argument.add_argument('--word_dim', type=int, default=100)
    argument.add_argument('--char_dim', type=int, default=30)
    argument.add_argument('--char_embedding_dim', type=int, default=30)
    argument.add_argument('--hidden_dim', type=int, default=600)
    argument.add_argument('--max_word_length', type=int, default=100)
    argument.add_argument('--max_sentence_length', type=int, default=300)
    argument.add_argument('--num_layers', type=int, default=1)
    argument.add_argument('--use_flair', type=str, default='False')
    argument.add_argument('--char_window_size', type=int, default=3)
    argument.add_argument('--extra_word_feature', type=str, default='True')
    argument.add_argument('--extra_char_feature', type=str, default='True')
    # configuration for pretrained models
    argument.add_argument('--model_name', type=str, default='bert-base-cased')
    argument.add_argument('--bert_size', type=int, default=768)
    argument.add_argument('--use_tagger', type=str, default='True')
    argument.add_argument('--tagger_name', type=str, choices=['LSTM', 'GRU'], default='LSTM')
    argument.add_argument('--tagger_size', type=int, default=600)
    argument.add_argument('--tagger_bidirectional', type=str, default='True')
    args = argument.parse_args()
    return args


def batch_to_device(batch, device):
    for key, value in batch.items():
        if key != 'label_ids_original':
            batch[key] = batch[key].to(device=device)


def pretrained_mode(args):
    train_source = os.path.join(args.dataset_dir, args.task_type, args.dataset_name, 'train.txt')
    valid_source = os.path.join(args.dataset_dir, args.task_type, args.dataset_name, 'test.txt')
    test_source = os.path.join(args.dataset_dir, args.task_type, args.dataset_name, 'test.txt')

    # train_source = os.path.join(args.dataset_dir, args.task_type, args.dataset_name, 'test.txt')
    # valid_source = os.path.join(args.dataset_dir, args.task_type, args.dataset_name, 'test.txt')
    # test_source = os.path.join(args.dataset_dir, args.task_type, args.dataset_name, 'test.txt')
    if torch.cuda.is_available() and torch.device != 'cpu':
        device = torch.device(device=args.device)
    else:
        device = torch.device(device='cpu')

    reader_ = READER.get(args.task_type, ner_reader)
    train_data = SeqDataset(train_source, read_method=reader_)
    valid_data = SeqDataset(valid_source, read_method=reader_)
    test_data = SeqDataset(test_source, read_method=reader_)
    label_list = train_data.get_label()
    label2idx = defaultdict()
    label2idx.default_factory = label2idx.__len__
    idx2label = {}
    for label in label_list:
        idx = label2idx[label]
        idx2label[idx] = label
    metric = METRIC.get(args.task_type, NERMetric)
    cache_dir = os.path.join(args.cache_dir, args.mode, args.model_name)
    if os.path.exists(cache_dir):
        config_ = AutoConfig.from_pretrained(args.model_name, hidden_size=args.bert_size)
        tokenizer_ = AutoTokenizer.from_pretrained(args.model_name)
    else:
        os.makedirs(cache_dir)
        config_ = AutoConfig.from_pretrained(args.model_name)
        tokenizer_ = AutoTokenizer.from_pretrained(args.model_name, fintuning_task=args.task_type, id2label=idx2label,
                                                   num_labels=len(idx2label))
        config_.save_pretrained(cache_dir)
        tokenizer_.save_pretrained(cache_dir)
    tagger_config = dict()
    tagger_config['hidden_size'] = args.tagger_size
    tagger_config['input_size'] = args.bert_size
    tagger_config['tagger_name'] = args.tagger_name
    tagger_config['use_context'] = eval(args.use_context)
    tagger_config['context_mechanism'] = args.context_mechanism
    tagger_config['bidirectional'] = eval(args.tagger_bidirectional)
    tagger_config['num_layers'] = args.num_layers
    collate_fn_seq = CollateFnSeq(tokenizer=tokenizer_, label2idx=label2idx)

    train_loader = DataLoader(train_data, collate_fn=collate_fn_seq, batch_size=args.batch_size)
    eval_loader = DataLoader(valid_data, collate_fn=collate_fn_seq, batch_size=args.batch_size)
    test_loader = DataLoader(test_data, collate_fn=collate_fn_seq, batch_size=16)
    setattr(config_, 'num_labels', len(idx2label))
    setattr(config_, 'use_tagger', eval(args.use_tagger))
    setattr(config_, 'tagger_config', tagger_config)
    setattr(config_, 'use_context', eval(args.use_context))
    setattr(config_, 'use_crf', eval(args.use_crf))
    setattr(config_, 'fix_pretrained', eval(args.fix_pretrained))
    model = BertForSeqTask(args.model_name, config_)
    model.to(device=device)
    # param_ = [n for n, p in model.named_parameters() if 'context' in n]
    param_groups = [
        {'params': [p for n, p in model.named_parameters() if 'tagger' in n], 'lr': args.learning_rate_tagger},
        {'params': [p for n, p in model.named_parameters() if 'bert' in n], },
        {'params': [p for n, p in model.named_parameters() if 'context' in n], 'lr': args.learning_rate_context},
        {'params': model.classifier.parameters(), 'lr': args.learning_rate_classifier}
    ]
    # optimizer = optim.AdamW(model.parameters(), lr=args.learning_rate, eps=args.adam_eps)
    optimizer = optim.AdamW(param_groups, lr=args.learning_rate, eps=args.adam_eps)
    # optimizer = optim.Adam(param_groups, lr=args.learning_rate, eps=args.adam_eps,
    # betas=(0.9,0.999))
    all_step = len(train_loader) * args.num_epoch
    scheduler = get_linear_schedule_with_warmup(optimizer, num_warmup_steps=args.warmup_step,
                                                num_training_steps=all_step)
    # scheduler_ = StepLR(optimizer, step_size=10, gamma=0.1)
    if eval(args.train):
        best_model_path = train(model,
                                train_loader,
                                eval_loader,
                                optimizer,
                                args,
                                metric,
                                device,
                                test_loader=test_loader,
                                warmup_strategy=scheduler,
                                num_labels=len(idx2label),
                                loss_fn=None,
                                lr_decay_scheduler=None,
                                idx2label=idx2label)
    else:
        best_model_path = args.best_model

    test(best_model_path, args, test_loader, device, metric(idx2label))


def collate_fn(tokenizer, batch_data=None):
    """
    process batch data before feeding into the model
    """
    sentences = []
    labels = []
    sent_length = []
    word_length = []
    chars = []
    for data in batch_data:
        sentences.append(data['sentence'])
        labels.append(data['labels'])
        sent_length.append(data['sentence_length'])
        word_length.append(data['word_length'])
        chars.append(data['chars'])
    input_batch = tokenizer.encode(sentences, labels, chars)
    input_batch['sentence_length'] = sent_length
    for key, value in input_batch.items():
        # print(key, value)
        if key != 'label_ids_original':
            input_batch[key] = torch.tensor(value)
    return input_batch


def light_mode(args):
    """
    initialize light models which are not pretrained model like BiLSTM etc
    """
    base_dir = os.path.join(args.log_dir, args.mode)
    log_wrapper(logger, base_dir=base_dir)
    dataset_path = os.path.join(args.dataset_dir, args.task_type, args.dataset_name)
    # train_path = os.path.join(dataset_path, 'train.txt')
    # eval_path = os.path.join(dataset_path, 'valid.txt')
    # test_path = os.path.join(dataset_path, 'test.txt')
    train_path = os.path.join(dataset_path, 'train.txt')
    eval_path = os.path.join(dataset_path, 'test.txt')
    test_path = os.path.join(dataset_path, 'test.txt')
    if torch.cuda.is_available() and torch.device != 'cpu':
        device = torch.device(device=args.device)
    else:
        device = torch.device(device='cpu')
    if eval(args.use_flair):
        pass
    else:
        cache_dir = os.path.join(args.cache_dir, args.mode, args.model_name)
        vector_cache = os.path.join(cache_dir, args.dataset_name + '.bin')
        if os.path.exists(vector_cache):
            word_vector = pickle.load(open(vector_cache, 'rb'))
        else:
            if not os.path.exists(args.cache_dir):
                os.makedirs(cache_dir)
            if os.path.exists(args.word_vector):
                word_vector = read_vector(word_vector_source=args.word_vector, vector_dim=args.word_dim)
                pickle.dump(word_vector, open(vector_cache, 'wb'))
            else:
                word_vector = None
        tokenizer_method = str.split
        tokenizer = NERTokenizer(tokenizer=tokenizer_method)
        reader_ = READER.get(args.task_type, ner_reader)
        word_counter, char_counter, label_counter \
            = build_counter(train_path, reader_, use_char=True, tokenizer=tokenizer)
        # num_labels = len(label_counter)
        word_alphabet, char_alphabet, label_alphabet \
            = init_alphabet(word_counter, char_counter, label_counter, use_crf=eval(args.use_crf))
        num_labels = len(label_alphabet) if eval(args.use_crf) else len(label_alphabet) - 1
        # print(label_alphabet.token2id)
        if word_vector:
            word_alphabet.add(word_vector)
        tokenizer.add_alphabet(word_alphabet, label_alphabet, char_alphabet)
        train_dataset = NERDataset(train_path, read_method=reader_)
        eval_dataset = NERDataset(eval_path, read_method=reader_)
        test_dataset = NERDataset(test_path, read_method=reader_)
        collate_fn_tokenizer = partial(collate_fn, tokenizer)
        train_loader = DataLoader(train_dataset, batch_size=args.batch_size, collate_fn=collate_fn_tokenizer)
        eval_loader = DataLoader(eval_dataset, batch_size=args.batch_size, collate_fn=collate_fn_tokenizer)
        test_loader = DataLoader(test_dataset, batch_size=args.batch_size, collate_fn=collate_fn_tokenizer)
        if word_vector:
            pretrained_vector = build_matrix(token_alphabet=word_alphabet,
                                             word_vector=word_vector,
                                             word_dim=args.word_dim)
        else:
            pretrained_vector = None
        extra_feature = (4 if eval(args.extra_word_feature) else 0) + (4 if eval(args.extra_char_feature) else 0)
        input_size = args.word_dim + (args.char_dim if eval(args.use_char) else 0) + extra_feature
        if extra_feature > 0:
            use_extra_feature = True
        else:
            use_extra_feature = False

        try:
            model_light = MODEL[args.model_name](len(word_alphabet),
                                                 len(char_alphabet),
                                                 input_size,
                                                 args.hidden_dim,
                                                 args.word_dim,
                                                 args.num_layers,
                                                 num_labels,
                                                 context_name=args.context_mechanism,
                                                 use_extra_features=use_extra_feature,
                                                 pretrained_vector=pretrained_vector,
                                                 use_char=eval(args.use_char),
                                                 use_context=eval(args.use_context),
                                                 use_crf=eval(args.use_crf),
                                                 char_embedding_dim=args.char_embedding_dim,
                                                 char_hidden_dim=args.char_dim,
                                                 kernel_size=args.char_window_size
                                                 )
        except KeyError:
            logger.info(f'{args.model_name} does not exist in supported model list')
            exit(1)
        model_light.to(device=device)
        param_group = [
            {'params': [p for n, p in model_light.named_parameters() if 'context' in n],
             'lr': args.learning_rate_context},
            {'params': [p for n, p in model_light.named_parameters() if 'context' not in n],
             }
        ]
        optimizer = torch.optim.SGD(param_group, lr=args.learning_rate, momentum=args.momentum)
        # optimizer = torch.optim.SGD(model_light.parameters(), lr=args.learning_rate, momentum=args.momentum)
        # scheduler = StepLR(optimizer, step_size=30, gamma=0.1)
        scheduler = None
        metric = METRIC.get(args.task_type, NERMetric)
        loss_fn = torch.nn.CrossEntropyLoss()
        best_model_path = train(model_light,
                                train_loader,
                                eval_loader,
                                optimizer,
                                args,
                                metric,
                                device,
                                test_loader=test_loader,
                                num_labels=num_labels,
                                loss_fn=loss_fn,
                                idx2label=label_alphabet,
                                lr_decay_scheduler=scheduler)
        test(best_model_path, args, test_loader, device,
             metric(label_alphabet, use_crf=eval(args.use_crf)))


def train(model,
          train_loader,
          eval_loader,
          optimizer,
          args,
          metric,
          device,
          test_loader=None,
          num_labels=None,
          loss_fn=None,
          warmup_strategy=None,
          lr_decay_scheduler=None,
          idx2label=None):
    """
    base train for all modes, return saved best model path
    """
    print(f'Training mode: {args.mode}; Using model name: {args.model_name}.....')
    num_parameters = 0
    for n, p in model.named_parameters():
        num_parameters += p.numel()
    print(f'Number of parameters: {num_parameters}')
    best_f1 = 0
    no_improve_step = 0
    all_step = len(train_loader) * args.num_epoch
    global_step = 0
    best_model_path = None
    for epoch in range(1, args.num_epoch + 1):
        local_step = 0
        epoch_loss = 0.
        epoch_step = len(train_loader)
        p_bar = tqdm.tqdm(train_loader)
        model.train()
        metric_ = metric(idx2label, use_crf=eval(args.use_crf))

        for batch in p_bar:
            batch_to_device(batch, device=device)
            if eval(args.use_crf):
                loss = model.loss(**batch)
                output, _ = model(**batch)
                # print(type(output))
            else:
                output, gate_weight = model(**batch)
                if args.mode == 'pretrained':
                    loss = output[0]
                else:
                    gold_labels = batch['label_ids']
                    loss = loss_fn(output.view(-1, num_labels), gold_labels.view(-1))
            # torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=args.grad_norm)
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            if warmup_strategy:
                warmup_strategy.step()
            local_step += 1
            global_step += 1
            epoch_loss += loss.item()
            p_bar.set_description(
                f"Epoch: {epoch}: Percentage: {local_step}/{epoch_step} Loss: {round(loss.item(), 2)}")
        eval_f1, fine_grained_f1 = evaluate(eval_loader, metric_, model, device,
                                            mode=args.mode, use_crf=eval(args.use_crf))
        if lr_decay_scheduler:
            lr_decay_scheduler.step()
        logger.info("-" * 50)
        logger.info(
            "Epoch: {}\t Global step: {} \t Avgloss: {:.2f}".format(epoch, global_step, epoch_loss / local_step))

        logger.info("Overall results: ")
        logger.info("precision {:.4f} recall {:.4f} f1 {:.4f}".format(eval_f1['precision'], eval_f1['recall'],
                                                                      eval_f1['f1']))
        logger.info("fine_grained_f1: ")
        for key, fined_f1 in fine_grained_f1.items():
            logger.info("{}: precision {:.4f} recall {:.4f} f1 {:.4f}".format(key, fined_f1['precision'],
                                                                              fined_f1['recall'],
                                                                              fined_f1['f1']))
        if eval_f1['f1'] > best_f1:
            logger.info(
                "This epoch has better f1 {:.4f} than current best f1 {:.4f}".format(eval_f1['f1'], best_f1))
            best_f1 = eval_f1['f1']
            logger.info(f"{global_step}/{all_step}")
            if args.mode == 'pretrained':
                save_name = "{}_{}.pth".format(args.model_name, epoch)
            else:
                save_name = "{}_{}.pth".format('lstm', epoch)
            if not os.path.exists(args.model_dir):
                os.makedirs(args.model_dir)
            best_model_path = os.path.join(args.model_dir, save_name)
            torch.save(model, best_model_path)
            no_improve_step = 0
        else:
            no_improve_step += 1
        logger.info('-' * 50)
        if no_improve_step > args.no_improve:
            logger.info("Early stop !!!!")
            break
    return best_model_path


def test(best_model_path, args, test_loader, device, metric):
    if best_model_path:
        logger.info("-" * 25 + 'test' + '-' * 25)
        logger.info(f'Best model: {os.path.basename(best_model_path)}')
        model_test = torch.load(best_model_path)
        best_file_dir = os.path.join(args.result_dir, args.dataset_name, args.mode)
        if not os.path.exists(best_file_dir):
            os.makedirs(best_file_dir)
        if args.mode == 'pretrained':
            prefix_ = args.model_name
            if eval(args.use_tagger):
                prefix_ = prefix_ + '_' + args.tagger_name
        else:
            prefix_ = 'LSTM'
        if eval(args.use_context):
            prefix_ = prefix_ + '_' + args.context_mechanism
        prefix_ = prefix_ + '_' + str(args.batch_size) + '_' + str(args.learning_rate)
        best_file_name = prefix_ + '.txt'
        besst_model_name = prefix_ + '.pth'

        f = open(os.path.join(best_file_dir, best_file_name), 'w')
        torch.save(model_test, os.path.join(best_file_dir, besst_model_name))
        f1, fined_f1 = evaluate(test_loader, metric, model_test,
                                device, args.mode, eval(args.use_crf))
        f.write(best_model_path + '\n')
        f.write("Overall results: \n")
        logger.info("Overall results: ")
        logger.info("precision {:.4f} recall {:.4f} f1 {:.4f}".format(f1['precision'], f1['recall'],
                                                                      f1['f1']))
        f.write("precision {:.4f} recall {:.4f} f1 {:.4f} \n".format(f1['precision'], f1['recall'],
                                                                     f1['f1']))
        logger.info("fine_grained_f1: ")
        f.write("fine_grained_f1: \n")
        for key, fined_f1 in fined_f1.items():
            logger.info("{}: precision {:.4f} recall {:.4f} f1 {:.4f}".format(key,
                                                                              fined_f1['precision'],
                                                                              fined_f1['recall'],
                                                                              fined_f1['f1']))
            f.write("{}: precision {:.4f} recall {:.4f} f1 {:.4f}\n".format(key,
                                                                            fined_f1['precision'],
                                                                            fined_f1['recall'],
                                                                            fined_f1['f1']))
        f.close()


def evaluate(data_loader, metrics, model, device, mode='pretrained', use_crf=False):
    """
    """
    model.eval()
    # metrics = NERMetric(id2token=idx2label)
    for batch in data_loader:
        batch_to_device(batch, device)
        output, gate_weight = model(**batch)
        # torch.save(gate_weight[0].cpu(),'global.pt')
        # torch.save(gate_weight[1].cpu(), 'local.pt')
        # break
        if mode == 'pretrained':
            if use_crf:
                logits = output
                gold_label = batch['labels_original']
            else:
                logits = torch.argmax(output[1], dim=-1)
                gold_label = batch['labels']
        else:
            if use_crf:
                logits = output
                gold_label = batch['label_ids_original']
            else:
                logits = torch.argmax(output, dim=-1)
                gold_label = batch['label_ids']
        metrics(logits, gold_label)
    f1, fine_grained_f1 = metrics.calculate_f1()
    return f1, fine_grained_f1


def feed_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.benchmark = False


if __name__ == "__main__":
    arguments = init_args()
    log_name = arguments.model_name
    if eval(arguments.use_tagger):
        log_name += '-tagger'
        arguments.model_dir += '-tagger'
    if eval(arguments.use_context):
        arguments.model_dir += '-context'
        log_name += '-context'
    feed_seed(arguments.seed)
    log_path = os.path.join('log', log_name)
    log_wrapper(logger, base_dir=log_path)
    train_mode = arguments.mode
    if train_mode == 'pretrained':
        pretrained_mode(arguments)
    else:
        light_mode(arguments)
