import socket
import threading


def recv_msg(udp_socket):
    while True:
        recv_data = udp_socket.recvfrom(1024)
        print(recv_data)


def send_msg(udp_socket, dest_ip, dest_port):
    while True:
        send_data = input("请输入要发送的内容：")
        udp_socket.sendto(send_data.encode("utf-8"), (dest_ip, dest_port))


def main():
    """完成udp聊天器的整体控制

    """
    # 创建套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # 绑定本地信息
    udp_socket.bind(("", 7788))
    # 获取对方信息
    dest_ip = input("请输入对方IP：")
    dest_port = int(input("请输入对方port："))

    # 创建两个线程
    t_recv = threading.Thread(target=recv_msg, args=(udp_socket,))
    t_send = threading.Thread(target=send_msg, args=(udp_socket, dest_ip, dest_port))

    # 接收数据
    t_recv.start()
    # 发送数据
    t_send.start()


if __name__ == '__main__':
    main()
