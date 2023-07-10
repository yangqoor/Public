from django.shortcuts import render,redirect
from django.template import loader,RequestContext
from django.http import HttpResponse
from booktest.models import BookInfo
# Create your views here.


def login_required(view_func):
    '''登录判断装饰器'''
    def wrapper(request, *view_args, **view_kwargs):
        # 判断用户是否登录
        if request.session.has_key('islogin'):
            # 用户已登录,调用对应的视图
            return view_func(request, *view_args, **view_kwargs)
        else:
            # 用户未登录,跳转到登录页
            return redirect('/login')
    return wrapper


def my_render(request, template_path, context={}):
    # 1.加载模板文件，获取一个模板对象
    temp = loader.get_template(template_path)
    # 2.定义模板上下文，给模板文件传数据
    context = RequestContext(request, context)
    # 3.模板渲染，产生一个替换后的html内容
    res_html = temp.render(context)
    # 4.返回应答
    return HttpResponse(res_html)


# /index
def index(request):
    # return my_render(request, 'booktest/index.html')
    return render(request, 'booktest/index.html')


# /index2
def index2(request):
    '''模板文件的加载顺序'''
    return render(request, 'booktest/index2.html')


# /temp_var
def temp_var(request):
    '''模板变量'''
    my_dict = {'title':'字典键值'}
    my_list = [1,2,3]
    book = BookInfo.objects.get(id=1)
    # 定义模板上下文
    context = {'my_dict':my_dict, 'my_list':my_list, 'book':book}
    return render(request, 'booktest/temp_var.html', context)


# /temp_tags
def temp_tags(request):
    '''模板标签'''
    # 1. 查找所有图书的信息
    books = BookInfo.objects.all()
    return render(request,'booktest/temp_tags.html', {'books':books})


# /temp_filter
def temp_filter(request):
    '''模板过滤器'''
    # 1. 查找所有图书的信息
    books = BookInfo.objects.all()
    return render(request,'booktest/temp_filter.html', {'books':books})


# /temp_inherit
def temp_inherit(request):
    '''模板继承'''
    return render(request, 'booktest/child.html')


# /html_escape
def html_escape(request):
    '''html转义'''
    return render(request, 'booktest/html_escape.html', {'content':'<h1>hello</h1>'})


def login(request):
    '''显示登录页面'''
    # 判断用户是否登录
    if request.session.has_key('islogin'):
        # 用户已登录, 跳转到修改密码页面
        return redirect('/change_pwd')
    else:
        # 用户未登录
        # 获取cookie username
        if 'username' in request.COOKIES:
            # 获取记住的用户名
            username = request.COOKIES['username']
        else:
            username = ''

        return render(request, 'booktest/login.html', {'username':username})


def login_check(request):
    '''登录校验视图'''
    # 1.获取提交的用户名和密码
    username = request.POST.get('username')
    password = request.POST.get('password')
    remember = request.POST.get('remember') # None on

    # 获取用户输入验证码
    vcode1 = request.POST.get('vcode')
    # 获取session中保存的验证码
    vcode2 = request.session.get('verifycode')

    # 进行验证码校验
    if vcode1 != vcode2:
        # 验证码错误
        return redirect('/login')

    # 2.进行登录的校验
    # 实际开发:根据用户名和密码查找数据库
    # 模拟: smart 123
    if username == 'smart' and password == '123':
        # 用户名密码正确，跳转到修改密码页面
        response = redirect('/change_pwd')

        # 判断是否需要记住用户名
        if remember == 'on':
            # 设置cookie username，过期时间1周
            response.set_cookie('username', username, max_age=7*24*3600)

        # 记住用户登录状态
        # 只有session中有islogin,就认为用户已登录
        request.session['islogin'] = True
        # 记住登录的用户名
        request.session['username'] = username
        # 返回应答
        return response
    else:
        # 用户名或密码错误，跳转到登录页面
        return redirect('/login')


# /change_pwd
@login_required
def change_pwd(request):
    '''显示修改密码页面'''
    # # 进行用户是否登录的判断
    # if not request.session.has_key('islogin'):
    #     # 用户未登录，跳转到登录
    #     return redirect('/login')

    return render(request, 'booktest/change_pwd.html')


# /change_pwd_action
@login_required
def change_pwd_action(request):
    '''模拟修改密码处理'''
    # # 进行用户是否登录的判断
    # if not request.session.has_key('islogin'):
    #     # 用户未登录，跳转到登录
    #     return redirect('/login')

    # 1.获取新密码
    pwd = request.POST.get('pwd')
    # 获取用户名
    username = request.session.get('username')
    # 2.实际开发的时候: 修改对应数据库中的内容...
    # 3.返回一个应答
    return HttpResponse('%s修改密码为:%s'%(username,pwd))


from PIL import Image, ImageDraw, ImageFont
from django.utils.six import BytesIO


# /verify_code
def verify_code(request):
    # 引入随机函数模块
    import random
    # 定义变量，用于画面的背景色、宽、高 RGB
    bgcolor = (random.randrange(20, 100), random.randrange(
        20, 100), 255)
    width = 100
    height = 25
    # 创建画面对象
    im = Image.new('RGB', (width, height), bgcolor)
    # 创建画笔对象
    draw = ImageDraw.Draw(im)
    # 调用画笔的point()函数绘制噪点
    for i in range(0, 100):
        xy = (random.randrange(0, width), random.randrange(0, height))
        fill = (random.randrange(0, 255), 255, random.randrange(0, 255))
        draw.point(xy, fill=fill)

    # 定义验证码的备选值
    str1 = 'ABCD123EFGHIJK456LMNOPQRS789TUVWXYZ0'
    # 随机选取4个值作为验证码
    rand_str = ''
    for i in range(0, 4):
        rand_str += str1[random.randrange(0, len(str1))]

    # 构造字体对象，ubuntu的字体路径为“/usr/share/fonts/truetype/freefont”
    font = ImageFont.truetype('FreeMono.ttf', 23)
    # 构造字体颜色
    fontcolor = (255, random.randrange(0, 255), random.randrange(0, 255))
    # 绘制4个字
    draw.text((5, 2), rand_str[0], font=font, fill=fontcolor)
    draw.text((25, 2), rand_str[1], font=font, fill=fontcolor)
    draw.text((50, 2), rand_str[2], font=font, fill=fontcolor)
    draw.text((75, 2), rand_str[3], font=font, fill=fontcolor)
    # 释放画笔
    del draw
    # 存入session，用于做进一步验证
    request.session['verifycode'] = rand_str
    # 内存文件操作
    buf = BytesIO()
    # 将图片保存在内存中，文件类型为png
    im.save(buf, 'png')
    # 将内存中的图片数据返回给客户端，MIME类型为图片png
    return HttpResponse(buf.getvalue(), 'image/png')


# /url_reverse
def url_reverse(request):
    '''url反向解析页面'''
    return render(request, 'booktest/url_reverse.html')


def show_args(request, a, b):
    return HttpResponse(a+':'+b)


def show_kwargs(request, c, d):
    return HttpResponse(c+":"+d)


from django.core.urlresolvers import reverse
# /test_redirect
def test_redirect(request):
    # 重定向到/index
    # return redirect('/index')
    # url = reverse('booktest:index')

    # 重定向到/show_args/1/2
    # url = reverse('booktest:show_args', args=(1,2))

    # 重定向到/show_kwargs/3/4
    url = reverse('booktest:show_kwargs', kwargs={'c':3, 'd':4})
    return redirect(url)



