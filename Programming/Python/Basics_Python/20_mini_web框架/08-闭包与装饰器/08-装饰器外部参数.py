def get_temp(temp_out):  # temp_out外部传参===>"李想"

    def get_test(test):
        def get_current_test(temp_in):  # temp_in===>"函数传参"
            data = test()  # 调用test()函数===>print("test")

            return data

        return get_current_test

    print(temp_out)  # temp_out外部传参===>"李想"
    return get_test


"""
    @get_temp("李想")分两步走 
    1.get_temp("李想")====>调用get_temp()函数 并返回get_test引用
    2.@加上第一步得到的get_test引用===>@get_test===>test=get_test(test) 
"""


@get_temp("李想")  # "李想"===>传送给get_temp(temp_out)
def test():
    print("test")

    return "函数返回值--123"


result = test("函数传参")

print(result)  # ====>test（）返回值 "函数返回值--123"