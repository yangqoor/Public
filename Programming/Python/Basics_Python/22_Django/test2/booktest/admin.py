from django.contrib import admin
from booktest.models import HeroInfo
# Register your models here.
# class BookInfoAdmin(admin.ModelAdmin):
#     '''模型后台管理类'''
#     pass

admin.site.register(HeroInfo)
