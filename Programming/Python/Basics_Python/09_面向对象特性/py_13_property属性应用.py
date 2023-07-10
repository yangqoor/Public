class Money:
    def __init__(self):
        self.__money = 0

    def get_money(self):
        return self.__money

    def set_money(self, value):
        if isinstance(value, int):
            self.__money = value
        else:
            print("ERROR:不是整形数字")

    money = property(get_money, set_money)


a = Money
a.money = 100   # set_money
print(a.money)  # get_money
