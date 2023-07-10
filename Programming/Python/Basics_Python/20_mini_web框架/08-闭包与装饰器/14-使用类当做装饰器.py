# def set_func_1(func):
# 	def call_func():
# 		# "<h1>haha</h1>"
# 		return "<h1>" + func() + "</h1>"
# 	return call_func


class Test(object):
    def __init__(self, func):
        self.func = func

    def __call__(self):
        print("这里是装饰器添加的功能.....")
        return self.func()

# Test.静态方法 也可以作为装饰器
# Test(get_str) 是一个实例对象，在 __init__方法中接收为实例属性
@Test  # 相当于get_str = Test(get_str)
def get_str():
    return "haha"


print(get_str())   # 对象() 直接调用 __call__ 方法
