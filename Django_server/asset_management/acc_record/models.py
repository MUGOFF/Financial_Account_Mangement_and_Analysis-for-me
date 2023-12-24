from django.db import models
from financial_account.models import *

# Create your models here.
# 단위거래 모델
class Transaction(models.Model):
    written_datetime = models.DateTimeField(auto_now_add=True) #작성일
    updated_datetime = models.DateTimeField(auto_now=True) #작성 날짜
    transaction_time = models.DateTimeField()
    transaction_from = models.ForeignKey(Financialaccount,on_delete=models.CASCADE,related_name='transaction')
    transaction_from_card = models.ForeignKey(Cardaccount,on_delete=models.CASCADE,related_name='transaction',blank=True,null=True)
    deposit_amount = models.IntegerField(default=0)
    withdrawal_amount = models.IntegerField(default=0)
    main_category = models.CharField(max_length=250, default='미지정')
    sub_category = models.ManyToManyField("Tag_Category", blank=True, related_name='transaction_bank',)
    description = models.TextField(blank=True)
    # transaction_to_name = models.ForeignKey('Company_Category_Correlation',on_delete=models.CASCADE,related_name='transaction', default ="현금",blank=True,null=True)
    # category_hooked = models.ForeignKey('Main_Category',on_delete=models.CASCADE,related_name='hookedtransaction',blank=True,null=True)
    
    def __str__(self):
        return str(self.transaction_time.strftime("%Y-%m-%d %H Hour"))
    
class Investment(models.Model):
    written_datetime = models.DateTimeField(auto_now_add=True) #작성일
    updated_datetime = models.DateTimeField(auto_now=True) #작성 날짜
    invest_time = models.DateTimeField()
    security_account = models.ForeignKey(Financialaccount,on_delete=models.CASCADE,related_name='investment')
    deal_price = models.IntegerField(default=0)
    item_amount = models.IntegerField(default=0)
    deal_type = models.CharField(max_length=250, default='미지정')
    item_category = models.CharField(max_length=250, default='미지정')
    invest_target_symbol = models.CharField(max_length=250, default='미지정')
    invest_target = models.CharField(max_length=250, default='미지정')
    description = models.TextField(blank=True)
    
    def __str__(self):
        return str(self.invest_time.strftime("%Y-%m-%d %H Hour"))

class Tag_Category(models.Model):
    sub_category = models.CharField(max_length=50, unique=True, primary_key=True)
    # upper_clas_category = models.ForeignKey("Main_Category", on_delete=models.CASCADE, verbose_name="category_id" ,related_name="sub_category")
    
    def __str__(self):
        return self.sub_category
    
#항목 통합
# class Main_Category(models.Model):
#     flow_category = models.CharField(max_length=50)
#     main_category = models.CharField(max_length=50)
    
#     def __str__(self):
#         return self.flow_category + " : " + self.main_category
    
# class Company_Category_Correlation(models.Model):
#     company_accountname = models.CharField(max_length=250, unique=True, primary_key=True)
#     company_commonname = models.CharField(max_length=250, blank=True)
#     category_hook = models.ForeignKey("Main_Category", on_delete=models.CASCADE, verbose_name="category_id" ,related_name="hooked_company", blank=True, null=True)
    
#     def __str__(self):
#         return  self.company_accountname + " : " + self.company_commonname
# #소비 항목
# class Cosume_category(models.Model):
#     main_category = models.CharField(max_length=50)
#     sub_category = models.CharField(max_length=50)
# #소득 항목
# class Income_category(models.Model):
#     main_category = models.CharField(max_length=50)
#     sub_category = models.CharField(max_length=50)   
    
    
    