import socket


def send(udp_socket):
    """发送消息

    :param udp_socket: 套接字对象
    """
    # 获取要发送的内容
    dest_ip = input("请输入对方的ip：")
    dest_port = int(input("请输入对方的port："))
    send_data = input("请输入要发送的消息：")

    udp_socket.sendto(send_data.encode("utf-8"), (dest_ip, dest_port))


def recv(udp_socket):
    """接收消息

    :param udp_socket:套接字对象
    """
    # recvfrom 无数据则等待，有多个数据则在系统堆积
    recv_data = udp_socket.recvfrom(1024)
    recv_msg = recv_data[0]  # 发送的内容
    recv_addr = recv_data[1]  # 发送方地址信息

    # 显示
    print("%s:%s" % (str(recv_addr), recv_msg.decode("gbk")))  # win的编码方式gbk


def main():

    # 创建套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 绑定本地信息
    local_add = ("", 6000)
    udp_socket.bind(local_add)  # 必须绑定自己的本地信息

    while True:

        print("-----------udp聊天器-----------")
        print("1.发送消息")
        print("2.接收消息")
        print("3.退出系统")
        print("-----------udp聊天器-----------")
        op = input("请输入功能：")

        if op == "1":
            # 1. 发送
            send(udp_socket)

        elif op == "2":
            # 2. 接收
            recv(udp_socket)

        elif op == "0":
            break

        else:
            print("输入有误，请重新输入")


if __name__ == '__main__':

    main()
