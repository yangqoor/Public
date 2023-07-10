name_list = ["zhangsan", "lisi", "zhangsan", "wangwu", "zhangsan", "zhangsan"]

# 使用迭代遍历列表
"""
顺序的从列表中依次获取数据，每次循环获得的数据
会保存在 变量1 中，在循环内部可以访问当前这一次获取的数据
for 变量1 in 列表名:
"""
for my_name in name_list:

    print("我的名字是 %s" % my_name)
