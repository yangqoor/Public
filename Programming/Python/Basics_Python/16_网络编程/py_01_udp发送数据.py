import socket


def main():
    # 创建一个 udp 套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 绑定本地信息
    # udp_socket.bind(("", 6000))

    while True:

        # 从键盘获取数据
        send_data = input("请输入要发送的数据：")
        # ('目标ip', port)
        dest_addr = ("192.168.0.100", 60000)

        # 如果输入 exit 退出
        if send_data == "exit":
            break

        # 可以使用 udp套接字收发数据
        # udp_socket.sendto(b"字节类型的内容字符串", ('目标ip', port))
        # udp_socket.sendto(b"Hello Python", ("192.168.0.100", 60000))
        udp_socket.sendto(send_data.encode("utf-8"), dest_addr)

    # 关闭套接字
    udp_socket.close()


if __name__ == '__main__':
    main()
