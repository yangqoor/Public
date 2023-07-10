name_list = ["zhangsan", "lisi", "zhangsan", "wangwu", "zhangsan", "zhangsan"]
"""
.append  .count   .insert  .reverse
.clear   .extend  .pop     .sort
.copy    .index   .remove
"""
# 1、取值和取索引
# list index out of range 列表索引超出范围
print(name_list[0])
# 知道数据内容，想确定列表中的位置
print(name_list.index("lisi"))

# 2、修改
name_list[1] = "李四"
# list assignment index out of range 列表指定索引超范围
# name_list[3] = "wangyi"

# 3、增加
# append 方法列表末尾追加数据
name_list.append("王小二")
# insert 方法列表指定位置追加数据
name_list.insert(1, "小美")
# extend 方法可以将其他列表的完整内容追加到当前列表末尾
temp_list = ["孙悟空", "猪八戒"]
name_list.extend(temp_list)

# 4、删除
# remove 方法删除指定数据
name_list.remove("wangwu")
# pop 方法默认会删除最后一个元素
# Remove and return item at index (default last).
name_list.pop()
# Raises IndexError if list is empty
# or index is out of range.
name_list.pop(2)
# clear 清空整个列表
# name_list.clear()

# del 关键字也可删除列表指定元素
# 本质为从内存中删除，删除整个变量后，该变量不可使用
# del 列表名[索引]
del name_list[2]

print(name_list)

# len (length)统计列表中元素的总数
print("列中包含 %d 个元素" % len(name_list))
# count 统计列表中某一数据出现的次数
print("列表中zhangsan出现了 %d 次" % name_list.count("zhangsan"))

# remove 方法删除第一个出现的数据
# Remove first occurrence of value.
# Raises ValueError if the value is not present.
name_list.remove("zhangsan")

print(name_list)
