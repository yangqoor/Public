import socket


def service_client(new_socket):
    """为客户端返回数据"""
    # 1. 接收浏览器发送过来的请求
    # GET / HTTP/1.1
    request = new_socket.recv(1024)
    print(request)

    # 2. 返回http格式的数据给浏览器
    # 2.1 准备给浏览器的数据 ----- header
    response = "HTTP/1.1 200 OK\r\n"     # \r\n 表示换行，兼容win
    response += "\r\n"
    # 2.2 准备给浏览器的数据 ----- body
    response += "<h1>hahaha</h1>"   # h1 字体最大 h6 最小
    new_socket.send(response.encode("utf-8"))

    # 关闭套接字
    new_socket.close()


def main():
    """完成整体的控制"""
    # 1. 创建套接字
    tcp_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # ### 设置服务器 close 即4次挥手结束后，资源立即释放
    tcp_server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # 2. 绑定
    tcp_server_socket.bind(("", 7888))
    # 3. 变为监听套接字
    tcp_server_socket.listen(128)

    while True:
        # 4. 等待新客户的链接
        new_socket, client_addr = tcp_server_socket.accept()
        # 5. 为这个客户端服务
        service_client(new_socket)

    # 关闭监听套接字
    tcp_server_socket.close()


if __name__ == '__main__':
    main()
