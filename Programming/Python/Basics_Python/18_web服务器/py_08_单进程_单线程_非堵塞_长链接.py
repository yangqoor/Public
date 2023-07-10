import socket
import re
import select


def service_client(new_socket, request):
    """为客户端返回数据"""
    # 1. 接收浏览器发送过来的请求
    # GET / HTTP/1.1
    # request = new_socket.recv(1024).decode("utf-8")
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

        response_body = html_content

        response_header = "HTTP/1.1 200 OK\r\n"
        response_header += "Content-Length:%d\r\n" % len(response_body)
        response_header += "\r\n"
        response = response_header.encode("utf-8") + response_body

        new_socket.send(response)

    # 不再需要关闭套接字
    # new_socket.close()


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
    tcp_server_socket.setblocking(False)  # 将套接字变为非堵塞

    # 创建一个 epoll 对象
    epl = select.epoll()
    # 将监听套接字对应的 fd 注册到 epoll 中
    epl.register(tcp_server_socket.fileno(), select.EPOLLIN)
    # 定义一个字典{fd:new_socket}
    fd_event_dict = dict()

    while True:
        # 默认堵塞，直到os检测到数据到来，通过事件通知方式告诉应用程序，此时解堵塞
        fd_event_list = epl.poll()    # 返回一个列表
        # [(fd, event), (套接字对应的文件描述符，对应的事件 eg：可以通过recv接收)]
        for fd, event in fd_event_list:
            if fd == tcp_server_socket.fileno():
                # 等待新客户的链接
                new_socket, client_addr = tcp_server_socket.accept()
                # 将新的套接字也注册到 epoll 中
                epl.register(new_socket.fileno(), select.EPOLLIN)
                # 将新套接字的{fd:new_socket对象}添加到字典中
                fd_event_dict[new_socket.fileno()] = new_socket
            elif event == select.EPOLLIN:
                # 判断已经连接的客户端是否有数据发送过来
                recv_data = fd_event_dict[fd].recv(1024).decode("utf-8")
                if recv_data:
                    service_client(fd_event_dict[fd], recv_data)
                else:
                    fd_event_dict[fd].close()
                    epl.unregister(fd)
                    del fd_event_dict[fd]

    # 关闭监听套接字
    tcp_server_socket.close()


if __name__ == '__main__':
    main()
