import re
from base64 import decode

"""
URL_FUNC_DICT = {
    "/index.html": index,
    "/center.html": center
}
"""

URL_FUNC_DICT = dict()


def route(url):
    def set_func(func):
        # URL_FUNC_DICT["/index.py"] = index
        URL_FUNC_DICT[url] = func

        def call_func(*args, **kwargs):
            return func(*args, **kwargs)

        return call_func

    return set_func


@route("/index.html")
def index():
    # print("------1--------")
    # 报错：'gbk' codec can't decode byte 0xaa in position 216: illegal multibyte sequen
    # open 中添加 encoding='UTF-8'
    with open("./templates/index.html", encoding='UTF-8') as f:
        print("------2--------")
        content = f.read()
    print("------3--------")
    my_stock_info = "哈哈哈哈 这是你的本月名称....."

    content = re.sub(r"\{%content%\}", my_stock_info, content)
    print("------4--------")
    return content


@route("/center.html")
def center():
    with open("./templates/center.html", encoding='UTF-8') as f:
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
        return URL_FUNC_DICT[file_name]()
    except Exception as ret:
        return "产生了异常：%s" % str(ret)
