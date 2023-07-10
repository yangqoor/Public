try:
    # 不能确定正确执行的代码
    num = int(input("请输入一个整数"))

    result = 8 / num
# 错误信息的最后一行的首个单词为 错误类型
except ZeroDivisionError:
    # 错误处理
    print("除0错误")
# except ValueError:
#     # 错误处理
#     print("请输入正确的整数")
# 假设错误没有预判到
except Exception as result:
    print("未知错误 %s" % result)

print("-" * 50)
