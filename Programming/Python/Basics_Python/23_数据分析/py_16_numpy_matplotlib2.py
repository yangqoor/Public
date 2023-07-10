import numpy as np
from matplotlib import pyplot as plt
import matplotlib

font = {'family': 'SimSun',
        'size': 12}
matplotlib.rc("font", **font)

us_file_path = "./database/US_video_data_numbers.csv"
gb_file_path = "./database/GB_video_data_numbers.csv_video_data_numbers.csv"

# np.loadtxt(fname,dtype数据类型=np.float,delimiter分隔符=None,skiprows逃过前n行=0,
# usecols读取指定列，元组或列表=None,unpack转置=False)
gb_data = np.loadtxt(us_file_path, dtype="int", delimiter=",")

# 筛选数据
gb_data = gb_data[gb_data[:, 1] <= 500000]

# 获取评论和喜欢数据
t_uk_comments = gb_data[:, -1]
t_uk_like = gb_data[:, 1]


# 绘图
plt.figure(figsize=(20, 8), dpi=80)

plt.scatter(t_uk_like, t_uk_comments)

plt.show()
