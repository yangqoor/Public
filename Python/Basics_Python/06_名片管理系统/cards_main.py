#! /usr/bin/python3

# 保存主程序功能代码
import cards_tools
# 死循环，由用户决定什么时间停止
while True:

    # TODO(小明) 显示功能菜单
    cards_tools.show_menu()

    action_str = input("请选择希望执行的操作：")
    print("您选择的操作是[%s]" % action_str)

    # 1,2,3 针对名片的操作
    # 直接对字符串判断，避免数据格式转换
    if action_str in ["1", "2", "3"]:

        # 新增名片
        if action_str == "1":
            cards_tools.new_card()
            # pass
        # 显示全部
        elif action_str == "2":
            cards_tools.show_all()
            # pass
        # 查询名片
        elif action_str == "3":
            cards_tools.search_card()
            # pass

        # 如果开发程序时，不希望立刻执行分支内部的代码
        # 可以使用 pass 关键字表示一个占位符，保证代码结构正确
        # pass 不会执行任何操作
        # pass
    # 0 退出系统
    elif action_str == "0":
        print("欢迎再次使用名片管理系统！")
        break
        # pass

    # 其他输入内容错误
    else:
        print("您的输入不正确，请重新选择")
