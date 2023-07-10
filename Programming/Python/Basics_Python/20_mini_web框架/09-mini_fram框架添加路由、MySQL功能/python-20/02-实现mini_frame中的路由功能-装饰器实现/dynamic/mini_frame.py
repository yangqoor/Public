import re

"""用来存放url路由映射
URL_FUNC_DICT = {
    "/index.py": index,
    "/center.py": center
}
"""

URL_FUNC_DICT = dict()


def route(url):
    def set_func(func):
        # URL_FUNC_DICT["/index.py"] = index 函数的引用作为字典的 value
        # 添加键值对，key是需要访问的url，value是当这个url需要访问的时候，需要调用的函数引用
        URL_FUNC_DICT[url] = func
        # 此时只需要函数的引用，不需要返回值
        # def call_func(*args, **kwargs):
        #   return func(*args, **kwargs)
        # return call_func

    return set_func


@route("/index.py")  # 相当于 @set_func  # index = set_func(index)
def index():
    with open("./templates/index.html", encoding="utf-8") as f:
        content = f.read()

    my_stock_info = "哈哈哈哈 这是你的本月名称....."

    content = re.sub(r"\{%content%\}", my_stock_info, content)

    return content


@route("/center.py")
def center():
    with open("./templates/center.html", encoding="utf-8") as f:
        content = f.read()

    my_stock_info = "这里是从mysql查询出来的数据。。。"

    content = re.sub(r"\{%content%\}", my_stock_info, content)

    return content


def application(env, start_response):
    start_response('200 OK', [('Content-Type', 'text/html;charset=utf-8')])

    file_name = env['PATH_INFO']
    # file_name = "/index.py"

    """
    if file_name == "/index.py":
        return index()
    elif file_name == "/center.py":
        return center()
    else:
        return 'Hello World! 我爱你中国....'
    """

    try:
        # func = URL_FUNC_DICT[file_name]
        # return func()
        # 此时字典里的value为函数的引用
        return URL_FUNC_DICT[file_name]()
    except Exception as ret:
        return "产生了异常：%s" % str(ret)
