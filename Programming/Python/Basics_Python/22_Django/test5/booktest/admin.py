from django.contrib import admin
from booktest.models import AreaInfo,PicTest
# Register your models here.

class AreaStackedInline(admin.StackedInline):
    # 写多类的名字
    model = AreaInfo
    extra = 2

class AreaTabularInline(admin.TabularInline):
    model = AreaInfo
    extra = 2

class AreaInfoAdmin(admin.ModelAdmin):
    '''地区模型管理类'''
    list_per_page = 10 # 指定每页显示10条数据
    list_display = ['id', 'atitle', 'title', 'parent']
    actions_on_bottom = True
    actions_on_top = False
    list_filter = ['atitle'] # 列表页右侧过滤栏
    search_fields = ['atitle'] # 列表页上方的搜索框

    # fields = ['aParent', 'atitle']
    fieldsets = (
        ('基本', {'fields':['atitle']}),
        ('高级', {'fields':['aParent']})
    )

    # inlines = [AreaStackedInline]
    inlines = [AreaTabularInline]

admin.site.register(AreaInfo, AreaInfoAdmin)

admin.site.register(PicTest)
