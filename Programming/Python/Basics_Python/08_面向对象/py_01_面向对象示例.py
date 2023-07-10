class Cat:

    def eat(self):
        # 哪一个对象调用方法，self 就是哪一个对象的引用
        print("%s 爱吃鱼" % self.name)

    def drink(self):
        print("%s 要喝水" % self.name)


# 创建猫对象
tom = Cat()

tom.name = "Tom"                  # .属性名 赋值即可给对象添加属性

tom.eat()
tom.drink()

# 放在 方法调用之后 找不到属性，导致报错
tom.name = "Tom"                  # .属性名 赋值即可给对象添加属性

# 输出对象由哪一个类创建，以及内存地址，十六进制
print(tom)

# 在创建一个猫对象
lazy_cat = Cat()                  # 不同的对象，地址不同

lazy_cat.name = "大懒猫"

lazy_cat.eat()
lazy_cat.drink()

print(lazy_cat)

lazy_cat2 = lazy_cat              # 同一个对象，只是标签不同

print(lazy_cat2)
