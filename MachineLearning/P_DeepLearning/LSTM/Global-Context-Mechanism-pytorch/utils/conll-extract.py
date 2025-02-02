import os


def conll_formatter(f_r, f_w):
    for line in f_r:
        if line.startswith('#'):
            continue
        if line != '\t' and line != '\n':
            seg_line = line.strip().split('\t')
            word, pos_tag = seg_line[1], seg_line[4]
            line_input = word + ' ' + pos_tag
            f_w.write(line_input + '\n')
        else:
            f_w.write(line)


def main(directory):
    files = os.listdir(directory)
    for name in files:
        if 'train' in name:
            source_name, target_name = os.path.join(directory, name), os.path.join(directory, 'train.txt')
        elif 'dev' in name:
            source_name, target_name = os.path.join(directory, name), os.path.join(directory, 'valid.txt')
        elif 'test' in name:
            source_name, target_name = os.path.join(directory, name), os.path.join(directory, 'test.txt')
        else:
            continue
        with open(source_name, 'r') as f1, open(target_name, 'w') as f2:
            conll_formatter(f1, f2)


if __name__ == '__main__':
    base_dir = 'ud_eng_ewt'
    main(base_dir)