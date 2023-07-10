class Dog(object):

    def __init__(self, name):
        self.name = name

    def game(self):
        print("%s 蹦蹦跳跳的玩耍" % self.name)


class XiaoTianDog(Dog):

    def game(self):
        print("%s 飞到天上去玩耍。。。" % self.name)
        super().game()


class Person(object):

    def __init__(self, name):
        self.name = name

    def game_with_dog(self, dog):
        dog.game()
        print("%s 和 %s 快乐的玩耍" % (self.name, dog.name))


# 1. 创建一个狗对象
# wangcai = Dog("旺财")
wangcai = XiaoTianDog("飞天旺财")
# 2. 创建一个小明对象
xiaoming = Person("小明")

# 3. 让小明和狗玩的方法
xiaoming.game_with_dog(wangcai)
