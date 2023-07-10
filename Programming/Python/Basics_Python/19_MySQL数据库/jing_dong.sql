
-- 创建 "京东" 数据库
create database jing_dong charset=utf8;

-- 使用 "京东" 数据库
use jing_dong;

-- 创建一个商品goods数据表
create table goods(
    id int unsigned primary key auto_increment not null,
    name varchar(150) not null,
    cate_name varchar(40) not null,
    brand_name varchar(40) not null,
    price decimal(10,3) not null default 0,
    is_show bit not null default 1,
    is_saleoff bit not null default 0
);


-- 向goods表中插入数据

insert into goods values(0,'r510vc 15.6英寸笔记本','笔记本','华硕','3399',default,default); 
insert into goods values(0,'y400n 14.0英寸笔记本电脑','笔记本','联想','4999',default,default);
insert into goods values(0,'g150th 15.6英寸游戏本','游戏本','雷神','8499',default,default); 
insert into goods values(0,'x550cc 15.6英寸笔记本','笔记本','华硕','2799',default,default); 
insert into goods values(0,'x240 超极本','超级本','联想','4880',default,default); 
insert into goods values(0,'u330p 13.3英寸超极本','超级本','联想','4299',default,default); 
insert into goods values(0,'svp13226scb 触控超极本','超级本','索尼','7999',default,default); 
insert into goods values(0,'ipad mini 7.9英寸平板电脑','平板电脑','苹果','1998',default,default);
insert into goods values(0,'ipad air 9.7英寸平板电脑','平板电脑','苹果','3388',default,default); 
insert into goods values(0,'ipad mini 配备 retina 显示屏','平板电脑','苹果','2788',default,default); 
insert into goods values(0,'ideacentre c340 20英寸一体电脑 ','台式机','联想','3499',default,default); 
insert into goods values(0,'vostro 3800-r1206 台式电脑','台式机','戴尔','2899',default,default); 
insert into goods values(0,'imac me086ch/a 21.5英寸一体电脑','台式机','苹果','9188',default,default); 
insert into goods values(0,'at7-7414lp 台式电脑 linux ）','台式机','宏碁','3699',default,default); 
insert into goods values(0,'z220sff f4f06pa工作站','服务器/工作站','惠普','4288',default,default); 
insert into goods values(0,'poweredge ii服务器','服务器/工作站','戴尔','5388',default,default); 
insert into goods values(0,'mac pro专业级台式电脑','服务器/工作站','苹果','28888',default,default); 
insert into goods values(0,'hmz-t3w 头戴显示设备','笔记本配件','索尼','6999',0,default); 
insert into goods values(0,'商务双肩背包','笔记本配件','索尼','99',default,0); 
insert into goods values(0,'x3250 m4机架式服务器','服务器/工作站','ibm','6888',default,default); 
insert into goods values(0,'商务双肩背包','笔记本配件','索尼','99',default,default);

-- SQL语句的强化

    -- 查询类型cate_name为 '超极本' 的商品名称、价格

select name,price from goods where cate_name = '超级本';

    -- 显示商品的种类

select distinct cate_name from goods;
select cate_name from goods group by cate_name;
select cate_name,group_concat(name) from goods group by cate_name;

    -- 求所有电脑产品的平均价格,并且保留两位小数

select round(avg(price),2) as avg_price from goods;

    -- 显示每种商品的平均价格

select cate_name,avg(price) from goods group by cate_name;

    -- 查询每种类型的商品中 最贵、最便宜、平均价、数量

select cate_name,max(price),min(price),avg(price),count(*) from goods group by cate_name;

    -- 查询所有价格大于平均价格的商品，并且按价格降序排序

select id,name,price from goods 
where price > (select round(avg(price),2) as avg_price from goods) 
order by price desc;

    -- 查询每种类型中最贵的电脑信息

select * from goods
inner join 
    (
        select
        cate_name, 
        max(price) as max_price, 
        min(price) as min_price, 
        avg(price) as avg_price, 
        count(*) from goods group by cate_name
    ) as goods_new_info 
on goods.cate_name=goods_new_info.cate_name and goods.price=goods_new_info.max_price;

-- 2. 创建 "商品分类"" 表

-- 创建商品分类表
create table if not exists goods_cates(
    id int unsigned primary key auto_increment,
    name varchar(40) not null
);

    -- 查询goods表中商品的种类

select cate_name from goods group by cate_name;

    -- 将分组结果写入到goods_cates数据表

insert into goods_cates (name) select cate_name from goods group by cate_name;

-- 3. 同步表数据

    -- 通过goods_cates数据表来更新goods表

update goods as g inner join goods_cates as c on g.cate_name=c.name set g.cate_name=c.id;


-- 4. 创建 "商品品牌表" 表

    --通过create...select来创建数据表并且同时写入记录,一步到位

-- select brand_name from goods group by brand_name;

-- 在创建数据表的时候一起插入数据
-- 注意: 需要对brand_name 用as起别名，否则name字段就没有值
create table goods_brands (
    id int unsigned primary key auto_increment,
    name varchar(40) not null) select brand_name as name from goods group by brand_name;

-- 5. 同步数据

    -- 通过goods_brands数据表来更新goods数据表

update goods as g inner join goods_brands as b on g.brand_name=b.name set g.brand_name=b.id;

-- 6. 修改表结构

    -- 查看 goods 的数据表结构,会发现 cate_name 和 brand_name对应的类型为 varchar 但是存储的都是数字

desc goods;

    -- 通过alter table语句修改表结构，可以一次性修改多个

alter table goods  
change cate_name cate_id int unsigned not null,
change brand_name brand_id int unsigned not null;

-- 7. 外键

    -- 分别在 goods_cates 和 goods_brands表中插入记录

insert into goods_cates(name) values ('路由器'),('交换机'),('网卡');
insert into goods_brands(name) values ('海尔'),('清华同方'),('神舟');

    -- 在 goods 数据表中写入任意记录

insert into goods (name,cate_id,brand_id,price)
values('LaserJet Pro P1606dn 黑白激光打印机', 12, 4,'1849');

    -- 查询所有商品的详细信息 (通过内连接)

select g.id,g.name,c.name,b.name,g.price from goods as g
inner join goods_cates as c on g.cate_id=c.id
inner join goods_brands as b on g.brand_id=b.id;

    -- 查询所有商品的详细信息 (通过左连接)

select g.id,g.name,c.name,b.name,g.price from goods as g
left join goods_cates as c on g.cate_id=c.id
left join goods_brands as b on g.brand_id=b.id;

    -- 如何防止无效信息的插入,就是可以在插入前判断类型或者品牌名称是否存在呢? 可以使用之前讲过的外键来解决

    -- 外键约束:对数据的有效性进行验证
    -- 关键字: foreign key,只有 innodb数据库引擎 支持外键约束
    -- 对于已经存在的数据表 如何更新外键约束

-- 给brand_id 添加外键约束成功
alter table goods add foreign key (brand_id) references goods_brands(id);
-- 给cate_id 添加外键失败
-- 会出现1452错误
-- 错误原因:已经添加了一个不存在的cate_id值12,因此需要先删除
alter table goods add foreign key (cate_id) references goods_cates(id);

    -- 如何在创建数据表的时候就设置外键约束呢?

    -- 注意: goods 中的 cate_id 的类型一定要和 goods_cates 表中的 id 类型一致

create table goods(
    id int primary key auto_increment not null,
    name varchar(40) default '',
    price decimal(5,2),
    cate_id int unsigned,
    brand_id int unsigned,
    is_show bit default 1,
    is_saleoff bit default 0,
    foreign key(cate_id) references goods_cates(id),
    foreign key(brand_id) references goods_brands(id)
);

    -- 如何取消外键约束

-- 需要先获取外键约束名称,该名称系统会自动生成,可以通过查看表创建语句来获取名称
show create table goods;
-- 获取名称之后就可以根据名称来删除外键约束
alter table goods drop foreign key 外键名称;

    -- 在实际开发中,很少会使用到外键约束,会极大的降低表更新的效率

-- sql注入
    sql = """insert into goods_brands (name) values("%s")""" % item_name

    -- 若输入：' or 1=1 or '1，则会被注入,参数化防止注入
    select * from goods where name='' or 1=1 or '1';

-- 创建账户&授权
-- grant 权限列表 on 数据库 to '用户名'@'访问主机' identified by '密码';

-- 创建一个laowang的账号，密码为123456，只能通过本地访问, 并且只能对jing_dong数据库中的所有表进行读操作
-- step1：使用root登录

mysql -uroot -p
-- 回车后写密码，然后回车

-- step2：创建账户并授予所有权限

grant select on jing_dong.* to 'laowang'@'localhost' identified by '123456';

--说明
--
--    可以操作python数据库的所有表，方式为:jing_dong.*
--    访问主机通常使用 百分号% 表示此账户可以使用任何ip的主机登录访问此数据库
--    访问主机可以设置成 localhost或具体的ip，表示只允许本机或特定主机访问
--
--    查看用户有哪些权限

show grants for laowang@localhost;

--step3：退出root的登录

quit

--step4：使用laowang账户登录

mysql -ulaowang -p
--回车后写密码，然后回车

-- 2.3 示例2
-- 创建一个laoli的账号，密码为12345678，可以任意电脑进行链接访问, 并且对jing_dong数据库中的所有表拥有所有权限
grant all privileges on jing_dong.* to "laoli"@"%" identified by "12345678"

--1. 修改权限

grant 权限名称 on 数据库 to 账户@主机 with grant option;

--2. 修改密码

--使用root登录，修改mysql数据库的user表

--    使用password()函数进行密码加密

    update user set authentication_string=password('新密码') where user='用户名';
--    例：
    update user set authentication_string=password('123') where user='laowang';

--    注意修改完成后需要刷新权限

    刷新权限：flush privileges

--3. 远程登录（危险慎用）

--如果向在一个Ubuntu中使用msyql命令远程连接另外一台mysql服务器的话，通过以下方式即可完成，但是此方法仅仅了解就好了，不要在实际生产环境中使用

--修改 /etc/mysql/mysql.conf.d/mysqld.cnf 文件

vim /etc/mysql/mysql.conf.d/mysqld.cnf

注释掉 bind_address=127.0.0.1
--然后重启msyql

service mysql restart

--在另外一台Ubuntu中进行连接测试
--
--如果依然连不上，可能原因：
--
--1) 网络不通
--
--    通过 ping xxx.xxx.xx.xxx可以发现网络是否正常
--
--2)查看数据库是否配置了bind_address参数
--
--    本地登录数据库查看my.cnf文件和数据库当前参数show variables like 'bind_address';
--
--    如果设置了bind_address=127.0.0.1 那么只能本地登录
--
--3)查看数据库是否设置了skip_networking参数
--
--    如果设置了该参数，那么只能本地登录mysql数据库
--
--4)端口指定是否正确
--4. 删除账户

--    语法1：使用root登录
--drop user '用户名'@'主机';
--例：
drop user 'laowang'@'%';

--    语法2：使用root登录，删除mysql数据库的user表中数据

delete from user where user='用户名';
--例：
delete from user where user='laowang';

-- 操作结束之后需要刷新权限
flush privileges

--    推荐使用语法1删除用户, 如果使用语法1删除失败，采用语法2方式
--
--3. 忘记 root 账户密码怎么办 !!
--
--    一般也轮不到我们来管理 root 账户,所以别瞎卖白粉的心了
--    万一呢? 到时候再来查http://blog.csdn.net/lxpbs8851/article/details/10895085



--. 配置主从同步的基本步骤
--
--有很多种配置主从同步的方法，可以总结为如下的步骤：
--
--    在主服务器上，必须开启二进制日志机制和配置一个独立的ID
--    在每一个从服务器上，配置一个唯一的ID，创建一个用来专门复制主服务器数据的账号
--    在开始复制进程前，在主服务器上记录二进制文件的位置信息
--    如果在开始复制之前，数据库中已经有数据，就必须先创建一个数据快照（可以使用mysqldump导出数据库，或者直接复制数据文件）
--    配置从服务器要连接的主服务器的IP地址和登陆授权，二进制日志文件名和位置
--
--4. 详细配置主从同步的方法
--
--主和从的身份可以自己指定，我们将虚拟机Ubuntu中MySQL作为主服务器，将Windows中的MySQL作为从服务器。 在主从设置前，要保证Ubuntu与Windows间的网络连通。
--4.1 备份主服务器原有数据到从服务器
--
--如果在设置主从同步前，主服务器上已有大量数据，可以使用mysqldump进行数据备份并还原到从服务器以实现数据的复制。
--4.1.1 在主服务器Ubuntu上进行备份，执行命令：

mysqldump -uroot -pmysql --all-databases --lock-all-tables > ~/master_db.sql

--说明
--
--    -u ：用户名
--    -p ：示密码
--    --all-databases ：导出所有数据库
--    --lock-all-tables ：执行操作时锁住所有表，防止操作时有数据修改
--    ~/master_db.sql :导出的备份数据（sql文件）位置，可自己指定

--4.1.2 在从服务器Windows上进行数据还原
--
--找到Windows上mysql命令的位置
--
--新打开的命令窗口，在这个窗口中可以执行类似在Ubuntu终端中执行的mysql命令
--
--将从主服务器Ubuntu中导出的文件复制到从服务器Windows中，可以将其放在上面mysql命令所在的文件夹中，方便还原使用
--
--在刚打开的命令黑窗口中执行还原操作:

mysql –uroot –pmysql < master_db.sql

--4.2 配置主服务器master（Ubuntu中的MySQL）
--4.2.1 编辑设置mysqld的配置文件，设置log_bin和server-id

sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf

--4.2.2 重启mysql服务

sudo service mysql restart

--4.2.3 登入主服务器Ubuntu中的mysql，创建用于从服务器同步数据使用的帐号

mysql –uroot –pmysql
-- *.*  所有数据库的所有权限
GRANT REPLICATION SLAVE ON *.* TO 'slave'@'%' identified by 'slave';

FLUSH PRIVILEGES;

--4.2.4 获取主服务器的二进制日志信息

SHOW MASTER STATUS;

--File为使用的日志文件名字，Position为使用的文件位置，这两个参数须记下，配置从服务器时会用到
--4.3 配置从服务器slave（Windows中的MySQL）
--4.3.1 找到Windows中MySQL的配置文件
--
--4.3.2 编辑my.ini文件，将server-id修改为2，并保存退出。
--
--4.3.3 打开windows服务管理
--
--可以在开始菜单中输入services.msc找到并运行
--
--4.3.4 在打开的服务管理中找到MySQL57，并重启该服务
--
--5. 进入windows的mysql，设置连接到master主服务器
--
change master to master_host='10.211.55.5', master_user='slave', master_password='slave',master_log_file='mysql-bin.000006', master_log_pos=590;
--
--注：
--
--    master_host：主服务器Ubuntu的ip地址
--    master_log_file: 前面查询到的主服务器日志文件名
--    master_log_pos: 前面查询到的主服务器日志文件位置
--
--6. 开启同步，查看同步状态
show slave status \G;
-- 若Slave_IO|SQL_Running:Yes 表示已同步

--7. 测试主从同步
--在Ubuntu的MySQL中（主服务器）创建一个数据库 在Windows的MySQL中（从服务器）查看新建的数据库是否存在