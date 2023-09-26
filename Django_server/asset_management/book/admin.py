from django.contrib import admin
from .models import *
# Register your models here.

class MonthlyBookSettingAdmin(admin.ModelAdmin):
    list_display = ("year", "month")
admin.site.register(MonthlyBookSetting, MonthlyBookSettingAdmin)