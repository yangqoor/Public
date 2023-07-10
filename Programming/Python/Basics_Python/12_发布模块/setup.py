from distutils.core import setup
# 如果报错 ModuleNotFoundError: No module named 'distutils.core'
# apt-get install python3-distutils
# https://docs.python.org/2/distutils/apiref.html

setup(
    name="message",                         # 包名
    version="1.0",                          # 版本
    description="消息模块",                 # 描述信息
    long_description="发送和接收消息模块",  # 完整的描述信息

    url="http://test.com",                  # 主页
    author="test",                          # 程序的作者
    author_email="test@gmail.com",          # 程序的作者的邮箱地址

    py_modules=["py_message.send_message",
                "py_message.receive_message"]
)
