def demo(num, num_list):
    print("函数内部")

    num = 123
    # 直接赋值修改的是可变数据类型的引用地址，
    # 不会修改原引用的内容，即不影响全局变量内容

    # num_list = [1, 2, 3]
    # 调用方法是在原引用地址上对可变数据类型的修改，
    # 即，方法修改会影响全局变量内容
    num_list.append(9)
    print(num)
    print(num_list)
    print("函数代码结束")


gl_num = 321
gl_num_list = [3, 2, 1]
demo(gl_num, gl_num_list)

print(gl_num)
print(gl_num_list)
