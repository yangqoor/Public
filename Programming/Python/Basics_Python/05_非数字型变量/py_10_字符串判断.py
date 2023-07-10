# 1. 判断只包含空白字符，\t\n\r 也属于空白字符
space_str = "    \t\n\r"
print(space_str.isspace())

# 2. 判断是否只包含数字 一般用 isdecimal 即可
# 1> 都不能判断小数
# num_str = "1.1"
# 2> unicode 字符串 后两者true
# num_str = "\u00b2"
# 3> 中文数字 isnumeric true
num_str = "一千零一"
print(num_str)
print(num_str.isdecimal())
print(num_str.isdigit())
print(num_str.isnumeric())
