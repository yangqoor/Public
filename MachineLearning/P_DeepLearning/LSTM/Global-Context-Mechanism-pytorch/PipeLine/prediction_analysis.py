import os
import argparse
from collections import defaultdict

import torch
from torch.utils.data import DataLoader
from transformers import AutoTokenizer, AutoConfig

from utils.file_reader import ner_reader, pos_reader
from utils.metrics import NERMetric, POSMetric
from PipeLine.glue_utils_transformer import SeqDataset, CollateFnSeq

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


def batch_to_device(batch, device):
    for key, value in batch.items():
        batch[key] = batch[key].to(device=device)


def init_args():
    arguments = argparse.ArgumentParser()
    arguments.add_argument('--task_type', type=str, default='NER')
    arguments.add_argument('--dataset_name', type=str, default='weibo')

    arguments.cache_dir('--cache_dir', type=str, default='/home/cs.aau.dk/ut65zx/bert-base-chinese')
    arguments.add_argument('--model_base', type=str, default='/home/cs.aau.dk/ut65zx')
    arguments.add_argument('dataset_base', type=str, default='Dataset')

    arguments.add_argument('--context_model', type=str, default='bert-base-chinese_13.pth')
    arguments.add_argument('--tagger_model', type=str, default='bert-base-chinese_11.pth')
    arguments.add_argument('--result_dir', type=str, default='result/')
    arguments.add_argument('--model_name', type=str, default='bert-base-chinese')

    arguments.add_argument('--bert_size', type=int, default=768)
    arguments.add_argument('--batch_size', type=int, default=16)

    arguments.add_argument('--device', type=str, default='cuda:0')

    args = arguments.parse_args()
    return args


def judge(context_model, tagger_model, data_loader, metric, result_dir, device, collect_fn):
    context_model.eval()
    tagger_model.eval()
    batch_id = 0
    for batch in data_loader:
        first = True
        batch_to_device(batch, device)
        context_pred, (global_tensor, local_tensor) = context_model(**batch)
        tagger_pred, _ = tagger_model(**batch)
        gold_label_ids = batch['label_ids']
        gold_label, gold_text = collect_fn.batch_labels, collect_fn.batch_texts
        context_pred_ = metric.get_entity(context_pred, is_gold=False, gold=gold_label_ids, ignore_index=-100)
        tagger_pred_ = metric.get_entity(tagger_pred, is_gold=False, gold=gold_label_ids, ignore_index=-100)
        batch_len = len(gold_text)
        for i in range(batch_len):
            context_item, tagger_item = context_pred_[i], tagger_pred_[i]
            gold_label_item, text_item = gold_label[i], gold_text[i]
            assert (context_item == gold_label_item) and (gold_label_item == tagger_item)
            if context_item != tagger_item:
                if first:
                    torch.save(global_tensor.cpu(), os.path.join(result_dir, f'global_tensor_{batch_id}.pt'))
                    torch.save(local_tensor.cpu(), os.path.join(result_dir, f'local_tensor_{batch_id}.pt'))
                    first = False
                difference_file = os.path.join(result_dir, f'difference_{str(batch_id)}.txt')
                with open(difference_file, 'a+') as f:
                    f.writelines(f'Itme number: {i+1}')
                    seq_len = len(gold_label_item)
                    for j in range(seq_len):
                        f.writelines(text_item[j] + '/t' + gold_label_item[j] + '/t'
                                     + context_item[j] + '/t' + tagger_item[j])
                    f.write('/n')
        batch_id += 1


def main():
    args = init_args()
    if not os.path.exists(args.result_dir):
        os.mkdir(args.result_dir)
    context_model_path = os.path.join(args.model_base, 'saved_model-tagger-context', args.context_model)
    tagger_model_path = os.path.join(args.model_base,'saved_mode-tagger', args.tagger_model)
    test_source = os.path.join(args.dataset_base, args.task_type, args.dataset_name, 'test.txt')
    train_source = os.path.join(args.dataset_base, args.task_type, args.dataset_name, 'train.txt')
    reader = READER.get(args.task_type, ner_reader)
    metric_class = METRIC.get(args.task_type, NERMetric)
    device = torch.device(args.device)

    if os.path.exists(args.cache_dir):
        configer = AutoConfig.from_pretrained(args.cache_dir, hidden_size=args.bert_size)
        tokenizer = AutoTokenizer.from_pretrained(args.cache_dir)
    else:
        configer = AutoConfig.from_pretrained(args.model_name)
        tokenizer = AutoTokenizer.from_pretrained(args.model_name)

        os.makedirs(args.cache_dir)
        configer.save_pretrained(args.cache_dir)
        tokenizer.save_pretrained(args.cache_dir)


    dataset_ = SeqDataset(test_source, read_method=reader)
    train_dataset_ = SeqDataset(train_source, read_method=reader)

    label_list = train_dataset_.get_label()
    label2idx = defaultdict()
    label2idx.default_factory = label2idx.__len__
    idx2label = {}
    for label_name in label_list:
        idx = label2idx[label_name]
        idx2label[idx] = label_name

    collect_fn = CollateFnSeq(tokenizer=tokenizer, label2idx=label2idx)
    loader = DataLoader(dataset_, collate_fn=collect_fn, batch_size=args.batch_size)
    context_model, tagger_model = torch.load(context_model_path), torch.load(tagger_model_path)
    metric = metric_class(id2token=idx2label)
    judge(context_model=context_model, tagger_model=tagger_model, data_loader=loader,
          metric=metric, result_dir=args.result_dir, device=device, collect_fn=collect_fn)


if __name__ == '__main__':
    main()
