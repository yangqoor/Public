# 字符串定义
str1 = "Hello World"
# 字符串中要用到“”时，用‘’定义字符串
str2 = '我的外号叫"小刘"'

print(str2)

# 取值
print(str1[0])

for char in str2:

    print(char, end="")
print("")

# 统计长度
print("字符串长度为%d" % len(str2))

# 统计次数
print("o出现的次数%d" % str1.count("o"))

# 某个子字符串的位置
print(str2.index('"'))
