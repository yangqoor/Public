import numpy as np

us_file_path = "./database/US_video_data_numbers.csv"
gb_file_path = "./database/GB_video_data_numbers.csv_video_data_numbers.csv"

# np.loadtxt(fname,dtype数据类型=np.float,delimiter分隔符=None,skiprows逃过前n行=0,
# usecols读取指定列，元组或列表=None,unpack转置=False)
t1 = np.loadtxt(us_file_path, dtype="int", delimiter=",", unpack=True)
t2 = np.loadtxt(us_file_path, dtype="int", delimiter=",")

print(t1)
print("*" * 10)
print(t2)
