"""
for 变量 in 集合:
    循环体
else：
    没有 break 退出循环，循环结束后会执行的代码
"""

students_list = [
    {"name": "小明",
     "age": 18,
     "gender": True,
     "height": 1.75,
     "weight": 75.5},
    {"name": "小美",
     "age": 16,
     "gender": False,
     "height": 1.75,
     "weight": 75.5}]

# 在学员列表中搜索指定的姓名
find_name = "张三"

for stu_dict in students_list:

    print(stu_dict)

    if stu_dict["name"] == find_name:

        print("找到了%s" % find_name)
        # 如果已经找到，则退出循环
        break
    # else:
    #     # 每循环一次都会输出提示信息
    #     print("抱歉没有找到%s" % find_name)

else:
    # 搜索结束时，所有的元素不符合目标，则
    # ”统一“输出提示信息
    print("抱歉没有找到%s" % find_name)

print("循环结束")
