from django.contrib import admin
from .models import *

# Register your models here.


class MonthlyBookSettingAdmin(admin.ModelAdmin):
    list_display = ("owner",)
admin.site.register(MonthlyBudgetSetting, MonthlyBookSettingAdmin)

class Company_Category_CorrelationAdmin(admin.ModelAdmin):
    list_display = ("owner", "company_accountname", "company_commonname", "category_hook")
admin.site.register(Company_Category_Correlation,Company_Category_CorrelationAdmin)

class CategorySettingAdmin(admin.ModelAdmin):
    list_display = ("owner",)
admin.site.register(CategorySetting, CategorySettingAdmin)