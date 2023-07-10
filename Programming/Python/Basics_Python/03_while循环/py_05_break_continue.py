i = 0

while i < 10:

    # 当某一条件满足时退出循环
    # if i == 3:
    #     break

    # 当某一条件满足时不执行后续重复的代码
    # 直接跳转回判断语句
    if i == 3:
        i += 1     # 重要：continue之前要处理计数器
        continue
    print(i)

    i += 1

print("over")
