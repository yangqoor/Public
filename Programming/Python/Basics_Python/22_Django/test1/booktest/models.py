from django.db import models


# 设计和表对应的类，模型类
# Create your models here.

# 一类
# 图书类
class BookInfo(models.Model):
    """图书模型类"""
    # 图书名称，CharField说明是一个字符串，max_length指定字符串的最大长度
    btitle = models.CharField(max_length=20)
    # 出版日期，DateField说明是一个日期类型
    bpub_date = models.DateField()

    def __str__(self):
        # 返回书名
        return self.btitle


# 多类
# 英雄人物类
# 英雄名 hname
# 性别 hgender
# 年龄　hage
# 备注　hcomment
# 关系属性　hbook，建立图书类和英雄人物类之间的一对多关系
class HeroInfo(models.Model):
    '''英雄人物模型类'''
    hname = models.CharField(max_length=20)  # 英雄名称
    # 性别，BooleanField说明是bool类型，default指定默认值，False代表男
    hgender = models.BooleanField(default=False)
    # 备注
    hcomment = models.CharField(max_length=128)
    # 关系属性　hbook，建立图书类和英雄人物类之间的一对多关系
    # 关系属性对应的表的字段名格式: 关系属性名_id
    hbook = models.ForeignKey('BookInfo', on_delete=models.CASCADE)

    def __str__(self):
        # 返回英雄名
        return self.hname
