def index():
    return "这是主页"


def login():
    return "这是登录页"


def application(environ, start_response):
    start_response("200 OK", [("Content-Type", "text/html;charset=utf-8")])

    file_name = environ["PATH_INFO"]
    if file_name == "/index.py":
        return index()
    elif file_name == "/login.py":
        return login()
    else:
        return "hello 中国"
