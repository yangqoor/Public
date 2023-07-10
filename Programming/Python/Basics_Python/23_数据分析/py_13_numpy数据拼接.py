import numpy as np

us_file_path = "./database/US_video_data_numbers.csv"
gb_file_path = "./database/GB_video_data_numbers.csv_video_data_numbers.csv"

# np.loadtxt(fname,dtype数据类型=np.float,delimiter分隔符=None,skiprows逃过前n行=0,
# usecols读取指定列，元组或列表=None,unpack转置=False)
us_data = np.loadtxt(us_file_path, dtype="int", delimiter=",")
gb_data = np.loadtxt(us_file_path, dtype="int", delimiter=",")

# 添加国家信息
# 构造全为 0 的数组
zeros_data = np.zeros((us_data.shape[0], 1)).astype(int)
ones_data = np.ones((gb_data.shape[0], 1)).astype(int)

us_data = np.hstack((zeros_data, us_data))
gb_data = np.hstack((ones_data, gb_data))

final_data = np.vstack((us_data, gb_data))
print(final_data)
