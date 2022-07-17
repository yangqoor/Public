# if 嵌套语句，注意语句的缩进即可
# 定义布尔变量，has_ticket 表示有车票
has_ticket = True

# 定义整型变量 knife_length 表示刀的长度 单位：cm
knife_length = 10

# 首先判断是否有车票，有车票允许安检
if has_ticket:
    print("车票检查通过，准备开始安检")

    # 安检时检查刀的长度，判断是否超过20cm
    if knife_length > 20:
        print("您携带的刀过长，长约%d cm" % knife_length)
        print("不许上车")
    else:
        print("安检通过，祝您旅途愉快！")

# 没有车票，请买票
else:
    print("请买票")
