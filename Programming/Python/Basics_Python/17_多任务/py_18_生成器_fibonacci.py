def create_num(all_num):
    a, b = 0, 1
    current_num = 0
    while current_num < all_num:
        # print(a)
        # 函数中有 yield 就不再是函数，而是一个生成器模板
        # yield 处暂停，将其后的值 返回 对应 for 后的 num，
        # 一次 for 结束后，从 yield 处继续执行
        yield a
        a, b = b, a + b
        current_num += 1


# 调用函数时，函数中有 yield
# 则不是调用函数，而是创建生成器对象，函数不再执行
obj = create_num(10)

for num in obj:
    print(num)
