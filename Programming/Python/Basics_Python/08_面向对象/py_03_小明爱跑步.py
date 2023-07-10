class Person:
    def __init__(self, name, weight):

        # self.属性 = 形参
        self.name = name
        self.weight = weight

    def __str__(self):

        return "我的名字叫 %s，体重是 %.2f 公斤" % (self.name, self.weight)

    def run(self):
        print("%s 爱跑步，跑步锻炼身体" % self.name)
        self.weight -= 0.5

    def eat(self):
        print("%s 是吃货，吃完这顿再减肥" % self.name)
        self.weight += 1


X_name = Person("小明", 75.0)

X_name.run()
X_name.eat()

M_name = Person("小美", 45)

M_name.run()
M_name.eat()

# 同一类的不同对象的属性互不干扰
print(X_name)
print(M_name)
