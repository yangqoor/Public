from django.conf.urls import url
from booktest import views

urlpatterns = [
    url(r'^static_test$', views.static_test), # 静态文件
    url(r'^index$', views.index), # 首页

    url(r'^show_upload$', views.show_upload), # 显示上传图片页面
    url(r'^upload_handle$', views.upload_handle), # 上传图片处理

    url(r'^show_area(?P<pindex>\d*)$', views.show_area), # 分页

    url(r'^areas$', views.areas), # 省市县选中案例
    url(r'^prov$', views.prov), # 获取所有省级地区的信息
    url(r'^city(\d+)$', views.city), # 获取省下面的市的信息
    url(r'^dis(\d+)$', views.city), # 获取市下面的县的信息
]
