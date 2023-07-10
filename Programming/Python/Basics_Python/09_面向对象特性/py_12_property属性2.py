class Foo():
    def get_bar(self):
        print("getter...")
        return 'Li'

    def set_bar(self, value):
        """必须两个参数"""
        print("setter...")
        return "set value" + value

    def del_bar(self):
        print("deleter...")
        return 'Li'

    BAR = property(get_bar, set_bar, del_bar, "description...")


obj = Foo()

obj.BAR                  # 自动调用第一个参数定义的方法
obj.BAR = "alex"         # 调用第二个参数定义的方法，并将value设置为alex

desc = Foo.BAR.__doc__   # 调用第三个参数定义的方法，展示说明信息
print(desc)

del obj.BAR              # 调用第四个参数定义的方法
