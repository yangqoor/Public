import socket


def main():

    # 1. 创建套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 2. 绑定自己的本地信息
    local_add = ("", 6000)
    udp_socket.bind(local_add)  # 必须绑定自己的本地信息

    # 3. 接收数据
    recv_data = udp_socket.recvfrom(1024)
    # recv_data 接收到的是一个元组 (b'内容', ('发送方ip', 发送方port))
    recv_msg = recv_data[0]   # 发送的内容
    recv_addr = recv_data[1]  # 发送方地址信息

    # 显示
    # print(recv_data)
    # print("%s:%s" % (str(recv_addr), recv_msg.decode("utf-8")))
    print("%s:%s" % (str(recv_addr), recv_msg.decode("gbk")))  # win的编码方式gbk

    # 关闭套接字
    udp_socket.close()


if __name__ == '__main__':

    main()
