class Animal:
    def eat(self):

        print("吃...")

    def drink(self):

        print("喝...")

    def run(self):

        print("跑...")

    def sleep(self):

        print("睡...")


class Dog(Animal):
    """开发狗类"""

    # 子类拥有父类的所有属性和方法
    def bark(self):

        print("汪！汪！汪！")


class XiaoTianQuan(Dog):

    def fly(self):

        print("哮天犬会飞")

    def bark(self):
        # 1. 针对子类特有的需求编写代码
        print("神一样地", end="")
        # 2. 使用 super() 调用原本在父类中封装的方法
        super().bark()

        # py2.x 版本常用，不推荐
        # 类名写错为子类，会出现递归死循环
        # Dog.bark(self)

        # 3. 增加其他子类的代码
        print("&^$%^#&^*&*^%%$^%$#$@$$")


class Cat(Animal):
    def catch(self):
        print("抓老鼠")


# 创建一个新对象 - 狗对象
wang = XiaoTianQuan()

wang.eat()
wang.drink()
wang.run()
wang.sleep()

# 子类的方法重写后，会调用子类方法
wang.bark()

wang.fly()
