import socket


def send_file_2_client(tcp_server_socket):

    while True:  # 为同一个客户服务多次
        print("等待客户端连接......")
        # 4. accept 等待客户端连接
        # client_socket 是新产生的为客户服务的套接字
        # tcp_server_socket 是监听套接字
        # client_addr 客户端信息
        new_client_socket, client_addr = tcp_server_socket.accept()

        print("客户到来，为客户%s服务" % str(client_addr))
        # print(new_client_socket)
        # 接收客户端发送过来的请求
        file_name = new_client_socket.recv(1024).decode("utf-8")
        print("客户%s请求为：%s" % (str(client_addr), file_name))

        #
        if file_name == "exit":
            break
        elif not file_name:
            break
        else:
            # 打开文件发送数据
            file_content = None
            try:
                f = open(file_name, "rb")
                file_content = f.read()
                f.close()
            except Exception as ret:
                print("没有要下载的文件！")
            # 判断是否成功打开文件
            if file_content:
                # 发送文件的数据
                new_client_socket.send(file_content)

    # 关闭accept返回的新的接字，即对该客户服务结束
    new_client_socket.close()

    print("客户%s的服务结束" % str(client_addr))


def main():
    # 1. socket 创建套接字
    tcp_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # 2. bind 绑定本地信息
    tcp_server_socket.bind(("", 7888))

    # 3. listen 让套接字由主动变为被动套接字
    tcp_server_socket.listen(128)

    while True:        # 为多个客户端服务
        # 调用文件发送函数
        send_file_2_client(tcp_server_socket)

    # 监听套接字关闭，不能再等待新的客户
    tcp_server_socket.close()


if __name__ == '__main__':

    main()
