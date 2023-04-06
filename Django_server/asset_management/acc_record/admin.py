from django.contrib import admin
from .models import *
# Register your models here.
admin.site.register(Transaction)
admin.site.register(Main_Category)
class Main_CategoryAdmin(admin.ModelAdmin):
    list_display = ("str", "flow_category","main_category")
admin.site.register(Tag_Category)
admin.site.register(Company_Category_Correlation)