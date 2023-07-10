class Pager:
    def __init__(self, current_page):
        # 用户当前请求的页码
        self.current_page = current_page
        # 每页默认显示10条数据
        self.per_items = 10

    @property
    def start(self):
        val = (self.current_page - 1) * self.per_items + 1
        return val

    @property
    def end(self):
        val = self.current_page * self.per_items
        return val


P = Pager(1)
# 调用 property 属性 方法后面不用再加 ()
# 看起来就是在获得属性值，可读性高
# 结果为 prop 的返回值
P.start
P.end
