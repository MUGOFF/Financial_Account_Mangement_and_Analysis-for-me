from django.contrib import admin
from .models import *
# Register your models here.
# @admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ("transaction_time", "transaction_from", "transaction_from_card", "transaction_to_name", "deposit_amount" ,"withdrawal_amount")
    list_filter = ('transaction_from', 'transaction_from_card')
    ordering = ['-transaction_time']
admin.site.register(Transaction, TransactionAdmin)
    
class Main_CategoryAdmin(admin.ModelAdmin):
    list_display = ("main_category", "flow_category")
admin.site.register(Main_Category, Main_CategoryAdmin)
admin.site.register(Tag_Category)
admin.site.register(Company_Category_Correlation)