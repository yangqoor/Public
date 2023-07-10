import socket


def main():
    # 创建socket
    tcp_client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # 目标服务器信息
    server_ip = input("请输入服务器IP：")
    server_port = int(input("请输入服务器port："))

    # 链接服务器
    tcp_client_socket.connect((server_ip, server_port))

    # 输入要下载的文件名
    download_file_name = input("请输入要下载的文件名：")

    # 将文件名发送到服务器
    tcp_client_socket.send(download_file_name.encode("utf-8"))

    # 接收服务器传过来的数据，最大接收1024字节
    recv_data = tcp_client_socket.recv(1024)
    print("接收到的数据为：", recv_data.decode("utf-8"))
    # 如果接收到数据再创建文件，否则不创建
    if recv_data:
        with open("新建" + download_file_name, "wb") as f:     # wb 二进制写入
            f.write(recv_data)

    # 关闭套接字
    tcp_client_socket.close()


if __name__ == '__main__':
    main()
