import socket
import re
import multiprocessing


class WSGIServers(object):
    def __init__(self):
        # 1. 创建套接字
        self.tcp_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # ### 设置服务器 close 即4次挥手结束后，资源立即释放
        self.tcp_server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # 2. 绑定
        self.tcp_server_socket.bind(("", 7888))
        # 3. 变为监听套接字
        self.tcp_server_socket.listen(128)

    def service_client(self, new_socket):
        """为客户端返回数据"""
        # 1. 接收浏览器发送过来的请求
        # GET / HTTP/1.1
        request = new_socket.recv(1024).decode("utf-8")
        # print(request)
        request_list = request.splitlines()
        print(request_list)

        # GET /index.html HTTP/1.1
        # get post put del
        ret = re.match(r"[^/]+(/[^ ]*)", request_list[0])
        if ret:
            file_name = ret.group(1)
            # print("*" * 50, file_name)
            if file_name == "/":
                file_name = "/index.html"
        else:
            file_name = "/index.html"

        # 2. 返回http格式的数据给浏览器
        # 2.1 准备给浏览器的数据 ----- header
        response = "HTTP/1.1 200 OK\r\n"  # \r\n 表示换行，兼容win
        response += "\r\n"
        # 2.2 准备给浏览器的数据 ----- body
        # response += "<h1>hahaha</h1>"   # h1 字体最大 h6 最小

        try:
            f = open("./html" + file_name, "rb")
        except:
            response = "HTTP/1.1 404 NOT FOUND\r\n"
            response += "\r\n"
            response += "----------file-not-find-----------"
            new_socket.send(response.encode("utf-8"))
        else:
            html_content = f.read()
            f.close()
            # 将 response header 发送给浏览器
            new_socket.send(response.encode("utf-8"))
            # 将 response body 发送给浏览器
            new_socket.send(html_content)

        # 关闭套接字
        new_socket.close()

    def run_forever(self):
        """完成整体的控制"""
        while True:
            # 4. 等待新客户的链接
            new_socket, client_addr = self.tcp_server_socket.accept()

            # 多进程为这个客户端服务
            p1 = multiprocessing.Process(target=self.service_client, args=(new_socket,))

            p1.start()

            # 多进程 会复制一份资源，相当于有两个new_socket
            # fd 文件描述符 就是一个数字，对应一个特殊文件，复制的new_socket 也对应系统底层的文件描述符，
            # 主进程和子进程的new_socket 需要全部关闭才是真正的关闭
            new_socket.close()

        # 关闭监听套接字
        tcp_server_socket.close()


def main():
    """控制整体，创建一个 web 服务器对象，调用run_forever方法运行"""
    wsgi_server = WSGIServers()
    wsgi_server.run_forever()


if __name__ == '__main__':
    main()
