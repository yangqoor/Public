class Dog:

    @staticmethod
    def run():

        # 不妨问实例属性，也不访问类属性
        print("小狗要跑。。。")


wangwang = Dog
wangwang.run()

# 通过类名，调用静态方法--不需要创建对象
Dog.run()
