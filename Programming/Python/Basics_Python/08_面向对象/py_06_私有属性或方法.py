class Women:

    def __init__(self, name):

        self.name = name
        self.__age = 18

    def __secret(self):
        # 对象的方法内部，可以访问对象的私有属性
        print("%s 的年龄是 %d" % (self.name, self.__age))


x = Women("小芳")

# 私有属性在外界不能被直接访问
# print(x.__age)

# 私有属性或方法只是伪私有 即变量名为 _类名__私有变量名
print(x._Women__age)

# x.__secret()
x._Women__secret()
