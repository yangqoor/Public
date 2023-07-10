from matplotlib import pyplot as plt

# 数据在x轴的位置，是一个可迭代对象
x = range(2, 26, 2)
# 数据在y轴的位置，是一个可迭代对象
y = [15, 13, 14.5, 17, 20, 25, 26, 26, 27, 22, 18, 15]

# 设置图片大小(宽，高),  dpi每英寸点个数
fig = plt.figure(figsize=(13, 8), dpi=80)

# 绘图
plt.plot(x, y)

# 设置x轴刻度
_xtick_lables = [i/2 for i in range(4, 49)]
plt.xticks(_xtick_lables[::3])
plt.yticks(range(min(y), max(y) + 1))

# 图像保存   .svg 矢量图，放大不会有锯齿
# plt.savefig("./test1.png")

# 展示图像
plt.show()
