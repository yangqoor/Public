from matplotlib import pyplot as plt
import random
import matplotlib

# win/linux适用
font = {'family': 'SimSun',
        'weight': 'bold'}
matplotlib.rc("font", **font)

# 数据在x轴的位置，是一个可迭代对象
x = range(0, 120)
# 数据在y轴的位置，是一个可迭代对象
y = [random.randint(20, 35) for i in range(120)]

# 设置图片大小(宽，高),  dpi每英寸点个数
fig = plt.figure(figsize=(20, 8), dpi=80)

# 绘图
plt.plot(x, y)

# 设置x轴刻度
# {}.format 格式化输出，相当于 %
_xtick_lables = ["10点{}分".format(i) for i in range(60)]
_xtick_lables += ["11点{}分".format(i) for i in range(60)]
# range 取不了步长，转化成列表才可以
# rotation 旋转标签
# matplotlib 默认不支持中文，，终端 fc-list :lang=zh 查看中文字体
plt.xticks(list(x)[::3], _xtick_lables[::3], rotation=45)
# plt.yticks(range(min(y), max(y) + 1))

# 图像保存   .svg 矢量图，放大不会有锯齿
# plt.savefig("./test1.png")

# 添加描述信息
plt.xlabel("时间")
plt.ylabel("温度/℃")
plt.title("10点到11点的气温变化")

# 展示图像
plt.show()
