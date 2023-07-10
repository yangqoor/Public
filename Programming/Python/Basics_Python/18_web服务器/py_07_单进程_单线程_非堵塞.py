import socket
import time


def main():

    tcp_server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp_server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    tcp_server_socket.bind(("", 7888))
    tcp_server_socket.listen(128)
    tcp_server_socket.setblocking(False)  # 非堵塞

    client_socket_list = list()

    while True:

        time.sleep(1)

        try:
            new_socket, new_addr = tcp_server_socket.accept()
        except Exception as ret:
            print("---没有客户端到来---")
        else:
            print("---只要没有异常就意味着来了一个新客户端")
            new_socket.setblocking(False)   # 设置套接字为非堵塞
            client_socket_list.append(new_socket)

        for client_socket in client_socket_list:
            try:
                recv_data = client_socket.recv(1024)
            except Exception as ret:
                # print(ret)
                print("---这个客户端没有发送过来数据---")
            else:
                print("---没有异常---")
                print(recv_data)
                if recv_data:
                    # 客户端发送过来了数据
                    print("---客户端发送过来了数据---")
                else:
                    # 客户端调用了 close ，导致空的recv返回
                    client_socket.close()
                    client_socket_list.remove(client_socket)
                    print("---客户端已经关闭---")


if __name__ == '__main__':
    main()
