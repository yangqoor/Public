class Cat:

    def __init__(self, new_name):
        # __init__ 内部定义的 self 属性，所有创建的对象都拥有该属性
        print("这是一个初始化方法")

        # self.属性名 = 属性初始值
        # self.name = "Tom"
        self.name = new_name

    def __del__(self):

        print("%s 死了" % self.name)

    def eat(self):
        # 哪一个对象调用方法，self 就是哪一个对象的引用
        print("%s 爱吃鱼" % self.name)

    def drink(self):
        print("%s 要喝水" % self.name)

    def __str__(self):

        # 必须返回一个字符串
        return "我是小猫[%s]" % self.name


# 使用 类名() 创建对象时，会自动调用初始化方法 __init__
tom = Cat("Tom")

tom.eat()
tom.drink()

# 再创建一个猫对象
# lazy_cat = Cat("大懒猫")                  # 不同的对象，地址不同
#
# lazy_cat.eat()
# lazy_cat.drink()

# del 关键字可以删除一个对象
# del tom

# 输出自定义的字符串需要调用 __str__
print(tom)

print("-" * 50)
