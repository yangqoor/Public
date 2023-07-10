# 通过pymsql模块 向表中加入十万条数据
from pymysql import connect


def main():
    # 创建Connection连接
    conn = connect(host='localhost', port=3306, database='jing_dong', user='root', password='123', charset='utf8')
    # 获得Cursor对象
    cursor = conn.cursor()
    # 插入10万次数据
    for i in range(100000):
        cursor.execute("insert into test_index values('ha-%d')" % i)
    # 提交数据
    conn.commit()


if __name__ == "__main__":
    main()

"""

    开启运行时间监测：

set profiling=1;

    查找第1万条数据ha-99999

select * from test_index where title='ha-99999';

    查看执行的时间：

show profiles;

    为表title_index的title列创建索引：

create index title_index on test_index(title(10));   -- varchar或char才需要在后加数字，数字与建立时相同

    执行查询语句：

select * from test_index where title='ha-99999';

    再次查看执行的时间

show profiles;

"""
