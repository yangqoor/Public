# 自定义过滤器
# 过滤器其实就是python函数
from django.template import Library

# 创建一个Library类的对象
register = Library()


# 自定义的过滤器函数，至少有一个参数，最多两个
@register.filter
def mod(num):
    '''判断num是否为偶数'''
    return num%2 == 0


@register.filter
def mod_val(num, val):
    '''判断num是否能被val整除'''
    return num%val == 0