from matplotlib import pyplot as plt
import matplotlib

# win/linux适用
font = {'family': 'SimSun',
        'weight': 'bold'}
matplotlib.rc("font", **font)

x = range(11, 31)   # range 最后一个数取不到
y = [1, 0, 1, 1, 2, 4, 3, 2, 3, 4, 4, 5, 6, 5, 4, 3, 3, 1, 1, 1]

fig = plt.figure(figsize=(20, 8), dpi=80)

plt.plot(x, y)

# 设置刻度
_xtick_lables = ["{}岁".format(i) for i in x]
plt.xticks(x, _xtick_lables)
# 网格 alpha 透明度
plt.grid(alpha=0.5)

plt.show()
