def create_num(all_num):
    a, b = 0, 1
    current_num = 0
    while current_num < all_num:
        ret = yield a   # yield 处暂停 返回 a 的值，send 传递yield的最终结果
        print(">>>>ret>>>>", ret)
        a, b = b, a + b
        current_num += 1

    return "Ok....."


obj = create_num(10)

res = next(obj)  # 第一次启动生成器一般用 next
print(res)       # next 启动

res = obj.send(None)   # send 启动，将参数传入 yield 的最终结论
print(res)
