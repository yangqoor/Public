# 字典是一个无序的集合，使用print输出时
# 通常输出顺序与定义顺序不一致
xiaoming = {"name": "小明", "age": 18, "gender": True, "height": 1.75, "weight": 75.5}

# 取值
print(xiaoming["name"])

# 增加
# key不存在新增键值对
xiaoming["grade"] = 5

# 修改
xiaoming["age"] = 5

# 删除
xiaoming.pop("gender")

print(xiaoming)
