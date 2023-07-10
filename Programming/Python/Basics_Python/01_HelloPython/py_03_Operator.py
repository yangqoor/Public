# 输入单价
price = float(input("请输入单价："))
# 输入购买量
weigh = float(input("请输入重量："))
# 计算总价
money = price * weigh

# 输出单价
print("苹果的单价为： %.02f 元" % price)
# 输出重量
print("买了 %.02f kg" % weigh)
# 输出总价
print("总价为 %.02f 元" % money)

# 输出详单
print("苹果的单价为： %.02f 元，购买了 %.02f kg，需要支付 %.02f 元" % (price, weigh, money))

name = "小明"                    # 字符串 str
age = 18                         # 整型 int
gender = True                    # 布尔 bool
student_num = 1                  # 整型 int
weight = 78.0                    # 浮点 float
scale = 0.123                    # 浮点 float

print("我的名字叫%s，今年%d岁，学号为%06d，数据比例为%.02f%%" % (name, age, student_num, scale*100))

