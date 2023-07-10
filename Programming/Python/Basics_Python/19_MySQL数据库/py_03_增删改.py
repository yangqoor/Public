from pymysql import *


def main():
    # 创建Connection连接
    conn = connect(host='localhost', port=3306, database='jing_dong', user='root', password='123', charset='utf8')
    # 获得Cursor对象
    cs1 = conn.cursor()
    # 执行insert语句，并返回受影响的行数：添加一条数据
    # 增加
    count = cs1.execute('''insert into goods_cates(name) values("硬盘")''')
    # 打印受影响的行数
    print(count)

    count = cs1.execute('insert into goods_cates(name) values("光盘")')
    print(count)

    # # 更新
    # count = cs1.execute('update goods_cates set name="机械硬盘" where name="硬盘"')
    # # 删除
    # count = cs1.execute('delete from goods_cates where id=6')

    # 提交之前的操作，如果之前已经之执行过多次的execute，那么就都进行提交
    # 但是递增的值已经改变
    conn.commit()   # 对数据库修改了，需要链接对象提交操作,不提交就不保存
    # conn.rollback()  # 回滚取消

    # 关闭Cursor对象
    cs1.close()
    # 关闭Connection对象
    conn.close()


if __name__ == '__main__':
    main()
