import numpy as np


def fill_ndarry(t1):
    for i in range(t1.shape[1]):
        temp_col = t1[:, i]
        nan_num = np.count_nonzero(temp_col != temp_col)
        if nan_num != 0:
            # 提取不为nan的array
            tem_not_nan_col = temp_col[temp_col == temp_col]
            # nan 赋值为平均值
            temp_col[np.isnan(temp_col)] = tem_not_nan_col.mean()
    return t1


if __name__ == '__main__':
    t1 = np.arange(24).reshape((6, 4)).astype("float")

    t1[1, 2:] = np.nan
    print(t1)

    t1 = fill_ndarry(t1)
    print(t1)
