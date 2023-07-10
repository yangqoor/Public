from pymysql import connect


class JD(object):

    def __init__(self):
        """创建数据库连接"""
        self.conn = connect(host='localhost', port=3306, user='root', password='123', database='jing_dong', charset='utf8')
        self.cursor = self.conn.cursor()

    def __del__(self):
        """关闭cursor对象"""
        self.cursor.close()
        self.conn.close()

    def execute_sql(self, sql):
        self.cursor.execute(sql)
        for temp in self.cursor.fetchall():
            print(temp)

    def show_all_items(self):
        """显示所有商品"""
        sql = "select * from goods;"
        self.execute_sql(sql)

    def show_cates(self):
        sql = "select name from goods_cates;"
        self.execute_sql(sql)

    def show_brands(self):
        sql = "select name from goods_brands;"
        self.execute_sql(sql)

    def add_brands(self):
        item_name = input("输入新商品分类名称：")
        sql = """insert into goods_brands (name) values("%s")""" % item_name
        self.cursor.execute(sql)
        self.conn.commit()    # 提交

    def get_info_by_name(self):
        find_name = input("请输入要查询的商品的名字：")

        # 不安全
        # 若输入：' or 1=1 or '1，则会被注入
        # sql = """select * from goods where name='%s';""" % find_name
        # print("--------->%s<----------" % sql)
        # self.execute_sql(sql)

        # 安全模式--->参数化
        sql = "select * from goods where name=%s"
        self.cursor.execute(sql, [find_name])
        self.cursor.fetchall()

    @staticmethod
    def print_menu():
        print("---------------京东---------------")
        print("1. 所有的商品")
        print("2. 所有的商品分类")
        print("3. 所有的商品品牌分类")
        print("4. 添加一个商品分类")
        print("5. 根据名字查询一件商品")
        return input("输入对应的功能序号")

    def run(self):
        while True:
            num = self.print_menu()
            if num == "1":
                # 查询所有的商品
                self.show_all_items()

            elif num == "2":
                # 查询分类
                self.show_cates()

            elif num == "3":
                # 查询品牌分类
                self.show_brands()

            elif num == "4":
                # 添加商品分类
                self.add_brands()

            elif num == "5":
                # 根据名字查询商品
                self.get_info_by_name()

            else:
                print("输入有误，请重新输入....")


def main():
    # 创建京东商城对象
    jd = JD()

    # 调用 run 方法运行
    jd.run()


if __name__ == '__main__':
    main()
