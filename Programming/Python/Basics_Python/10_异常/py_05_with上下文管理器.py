class File:

    def __init__(self, filename, mode):
        self.filename = filename
        self.mode = mode

    def __enter__(self):
        self.f = open(self.filename, self.mode)
        return self.f

    def __exit__(self, *args):
        self.f.close()


# 有__enter__和__exit__方法的对象上下文管理器
# 保证无论有无异常，资源都会关闭
with File("1.txt", "w") as f:
    f.write("hello")
