from matplotlib import pyplot as plt
import matplotlib

font = {'family': 'SimSun',
        'size': 12}
matplotlib.rc("font", **font)

a = ["猩球崛起3：终极之战", "敦刻尔克", "蜘蛛侠：英雄归来", "战狼2"]
b_16 = [15746, 312, 4497, 319]
b_15 = [12357, 156, 2045, 168]
b_14 = [2358, 399, 2358, 362]

bir_width = 0.2

x_14 = range(len(a))
x_15 = [i + bir_width for i in x_14]
x_16 = [i + bir_width * 2 for i in x_14]

plt.figure(figsize=(15, 8), dpi=80)

plt.bar(x_14, b_14, width=bir_width)
plt.bar(x_15, b_15, width=bir_width)
plt.bar(x_16, b_16, width=bir_width)

plt.xticks(x_15, a)

plt.legend(["9月14日", "9月15日", "9月16日"])

plt.show()
