def demo(*args, **kwargs):

    print(args)
    print(kwargs)


# 元组变量/字典变量
gl_num = (1, 2, 3, 4)
gl_dict = {"name": "小明", "age": 18}

demo(gl_num, gl_dict)
# 拆包语法，简化 元组/字典 变量的传递
demo(*gl_num, **gl_dict)

demo(1, 2, 3, 4, name="小明", age=18)
