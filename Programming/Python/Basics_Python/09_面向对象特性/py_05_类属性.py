class Tool(object):

    # 使用赋值语句定义类属性，记录工具对象的数量
    count = 0

    def __init__(self, name):
        self.name = name

        # 让类属性的值 +1
        Tool.count += 1


# 1. 创建工具对象
tool1 = Tool("斧头")
# print("工具对象总数 %d" % Tool.count)

tool2 = Tool("榔头")
tool3 = Tool("水桶")

# 不建议采用 对象名.类属性 方式
# 对象名.类属性 = 值 的操作只会给对象添加一个新属性
# 不会影响到类属性的值
tool3.count = 99
print("工具对象总数 %d" % tool3.count)

# 2. 输出工具对象总数
print("工具对象总数 %d" % Tool.count)
