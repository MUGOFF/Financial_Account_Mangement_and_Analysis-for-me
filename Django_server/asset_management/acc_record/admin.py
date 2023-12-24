from django.contrib import admin
from .models import *

# Register your models here.

# @admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    # list_display = ("transaction_time", "transaction_from", "transaction_from_card", "transaction_to_name", "deposit_amount" ,"withdrawal_amount",'written_datetime')
    list_display = ("transaction_time", "transaction_from", "transaction_from_card", "deposit_amount" ,"withdrawal_amount",'written_datetime')
    list_filter = ('transaction_from', 'transaction_from_card')
    ordering = ['-transaction_time']
admin.site.register(Transaction, TransactionAdmin)
    
class InvestmentAdmin(admin.ModelAdmin):
    # list_display = ("transaction_time", "transaction_from", "transaction_from_card", "transaction_to_name", "deposit_amount" ,"withdrawal_amount",'written_datetime')
    list_display = ("invest_time", "security_account", 'item_category', "invest_target", "deal_type", "deal_price", "item_amount")
    list_filter = ('security_account', 'item_category')
    ordering = ['-invest_time']
admin.site.register(Investment, InvestmentAdmin)

admin.site.register(Tag_Category)

# class Main_CategoryAdmin(admin.ModelAdmin):
#     list_display = ("main_category", "flow_category")
# admin.site.register(Main_Category, Main_CategoryAdmin)

# class Company_Category_CorrelationAdmin(admin.ModelAdmin):
#     list_display = ("company_accountname", "company_commonname", "category_hook")
# admin.site.register(Company_Category_Correlation,Company_Category_CorrelationAdmin)