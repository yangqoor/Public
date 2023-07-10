import time


def login():
    return "---login---welcome %s" % time.ctime()


def register():
    return "---register---welcome %s" % time.ctime()


def profile():
    return "---profile---welcome %s" % time.ctime()


def application(file_name):
    if file_name == "/login.py":
        return login()
    elif file_name == "/register.py":
        return register()
    else:
        return "not find"
