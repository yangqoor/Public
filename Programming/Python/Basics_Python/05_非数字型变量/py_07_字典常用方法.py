"""
x.clear      x.get        x.pop        x.update
x.copy       x.items      x.popitem    x.values
x.fromkeys   x.keys       x.setdefault
"""

x = {"name": "小明", "age": 18, "gender": True, "height": 1.75, "weight": 75.5}

# 统计键值对数量
print("字典长度为%d" % len(x))

# 合并字典
temp_dict = {"grade": "五年级", "age": 19}
# 若键值对存在，则覆盖原有键值对
x.update(temp_dict)

# 清空全部
# x.clear()

# 迭代遍历字典
# k为每次循环获得的key
for k in x:

    print("%s:%s" % (k, str(x[k])))
