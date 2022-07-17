def demo(num, num_list):
    print("函数开始")

    # num = num + num 赋值语句，不影响全局变量
    num += num

    # 列表变量的 += 不是相加再赋值，
    # 本质上是调用 .extend 方法
    num_list += num_list
    # num_list = num_list + num_list
    # num_list.extend(num_list)

    print(num)
    print(num_list)

    print("函数结束")


gl_num = 9
gl_list = [1, 2, 3]
demo(gl_num, gl_list)
print(gl_num)
print(gl_list)
