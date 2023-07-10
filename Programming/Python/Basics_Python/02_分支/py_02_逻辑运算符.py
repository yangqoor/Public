# 判断考试成绩
py_score = 85
c_score = 60
# 任一成绩大于60为及格
if py_score > 60 or c_score > 60:
    # 合格留下
    is_employee = True
else:
    print("考试不及格")

if is_employee:
    print("考试及格留下当员工")
