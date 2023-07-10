import socket


# noinspection PyUnreachableCode
def main():
    # 1. socket 创建套接字
    tcp_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # 2. bind 绑定本地信息
    tcp_server_socket.bind(("", 7888))

    # 3. listen 让套接字由主动变为被动
    tcp_server_socket.listen(128)

    while True:        # 为多个客户端服务

        print("等待客户端连接......")
        # 4. accept 等待客户端连接
        # client_socket 是新产生的为客户服务的套接字
        # tcp_server_socket 是监听套接字
        # client_addr 客户端信息
        new_client_socket, client_addr = tcp_server_socket.accept()

        print("客户到来，为客户%s服务" % str(client_addr))
        # print(new_client_socket)
        while True:        # 为同一个客户服务多次
            # 接收客户端发送过来的请求
            # recv 返回的 recv_data 仅仅是一个数据;recvfrom 返回的包括用户信息
            recv_data = new_client_socket.recv(1024)
            print("客户请求为：%s" % recv_data.decode("utf-8"))

            #
            if recv_data.decode("utf-8") == "exit":
                break
            elif not recv_data:
                break
            else:
                # 回送
                new_client_socket.send("哈哈".encode("utf-8"))

        # 关闭accept返回的新的套接字，即对该客户服务结束
        new_client_socket.close()

        print("客户%s的服务结束" % str(client_addr))

    # 监听套接字关闭，不能再等待新的客户
    tcp_server_socket.close()


if __name__ == '__main__':

    main()
