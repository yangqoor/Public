from django.shortcuts import render
from django.conf import settings
from django.http import HttpResponse, JsonResponse
from booktest.models import PicTest, AreaInfo

# Create your views here.

EXCLUDE_IPS = ['172.16.179.152']


def blocked_ips(view_func):
    def wrapper(request, *view_args, **view_kwargs):
        # 获取浏览器端的ip地址
        user_ip = request.META['REMOTE_ADDR']
        if user_ip in EXCLUDE_IPS:
            return HttpResponse('<h1>Forbidden</h1>')
        else:
            return view_func(request, *view_args, **view_kwargs)

    return wrapper


# /static_test
# @blocked_ips
def static_test(request):
    '''静态文件'''
    print(settings.STATICFILES_FINDERS)
    # ('django.contrib.staticfiles.finders.FileSystemFinder','django.contrib.staticfiles.finders.AppDirectoriesFinder')
    return render(request, 'booktest/static_test.html')


# @blocked_ips
def index(request):
    '''首页'''
    print('----index----')
    # num = 'a' + 1
    print(settings.FILE_UPLOAD_HANDLERS)
    return render(request, 'booktest/index.html')


# /show_upload
def show_upload(request):
    """显示上传图片页面"""
    return render(request, 'booktest/upload_pic.html')


# <class 'django.core.files.uploadedfile.InMemoryUploadedFile'>
# <class 'django.core.files.uploadedfile.TemporaryUploadedFile'>
def upload_handle(request):
    """上传图片处理"""
    # 1.获取上传文件的处理对象
    pic = request.FILES['pic']

    # 2.创建一个文件
    save_path = '%s/booktest/%s' % (settings.MEDIA_ROOT, pic.name)
    with open(save_path, 'wb') as f:
        # 3.获取上传文件的内容并写到创建的文件中
        for content in pic.chunks():
            f.write(content)

    # 4.在数据库中保存上传记录
    PicTest.objects.create(goods_pic='booktest/%s' % pic.name)

    # 5.返回
    return HttpResponse('ok')


# /show_area页码
# 前端访问的时候，需要传递页码
from django.core.paginator import Paginator


def show_area(request, pindex):
    '''分页'''
    # 1.查询出所有省级地区的信息
    areas = AreaInfo.objects.filter(aParent__isnull=True)
    # 2. 分页,每页显示10条
    paginator = Paginator(areas, 10)

    # 3. 获取第pindex页的内容
    if pindex == '':
        # 默认取第一页的内容
        pindex = 1
    else:
        pindex = int(pindex)
    # page是Page类的实例对象
    page = paginator.page(pindex)

    # 4.使用模板
    return render(request, 'booktest/show_area.html', {'page': page})


# /areas
def areas(request):
    '''省市县选中案例'''
    return render(request, 'booktest/areas.html')


# /prov
def prov(request):
    '''获取所有省级地区的信息'''
    # 1.获取所有省级地区的信息
    areas = AreaInfo.objects.filter(aParent__isnull=True)

    # 2.变量areas并拼接出json数据：atitle id
    areas_list = []
    for area in areas:
        areas_list.append((area.id, area.atitle))

    # 3.返回数据
    return JsonResponse({'data': areas_list})


def city(request, pid):
    '''获取pid的下级地区的信息'''
    # 1.获取pid对应地区的下级地区
    # area = AreaInfo.objects.get(id=pid)
    # areas = area.areainfo_set.all()
    areas = AreaInfo.objects.filter(aParent__id=pid)

    # 2.变量areas并拼接出json数据：atitle id
    areas_list = []
    for area in areas:
        areas_list.append((area.id, area.atitle))

    # 3.返回数据
    return JsonResponse({'data': areas_list})
