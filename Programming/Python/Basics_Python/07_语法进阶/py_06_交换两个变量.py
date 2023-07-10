a = 6
b = 100

# 1. 使用其他变量
# c = b
# b = a
# a = c

# 2. 不使用其他变量
# a = a + b
# b = a - b
# a = a - b

# 3. python 专有
# 使用多个变量接收一个元组
# 如果返回的数据类型是元组，小括号可以省略
# a, b = (b, a)
a, b = b, a

print(a)
print(b)
