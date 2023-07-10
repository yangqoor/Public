

def create_num(all_num):
    # print("------1------")
    a, b = 0, 1
    current_num = 0
    while current_num < all_num:
        # print("------2------")
        # print(a)
        # 函数中有 yield 就不再是函数，而是一个生成器模板
        # yield 处暂停，将其后的值 返回 对应 for 后的 num，
        # 一次 for 结束后，从 yield 处继续执行
        yield a
        # print("------3------")
        a, b = b, a + b
        current_num += 1
        # print("------4------")

    return "Ok....."


# 调用函数时，函数中有 yield
# 则不是调用函数，而是创建生成器对象，函数不再执行
obj = create_num(10)

# for num in obj:
#     print(num)

print("obj:", next(obj))      # next 启动迭代器
print("obj:", next(obj))

obj2 = create_num(2)     # 只是创建对象，对调用的"函数"无影响

while True:
    try:
        ret = next(obj2)
        print("obj2:", ret)
    except Exception as ret:
        print(ret.value)     # yield 函数中的return在异常中获取
        break
