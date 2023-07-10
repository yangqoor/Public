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
us_data = np.loadtxt(us_file_path, dtype="int", delimiter=",")
gb_data = np.loadtxt(us_file_path, dtype="int", delimiter=",")

# 获取评论数据
t_us_comments = us_data[:, -1]

# 裁切数据，选择比5000小的
t_us_comments = t_us_comments[t_us_comments <= 5000]

print(t_us_comments.max(), t_us_comments.min())

d = 250

bin_nums = (t_us_comments.max() - t_us_comments.min()) // d

# 绘图
plt.figure(figsize=(20, 8), dpi=80)

plt.hist(t_us_comments, bin_nums)

plt.show()
