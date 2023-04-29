from django.db import models
from financial_account.models import *

# Create your models here.
# 단위거래 모델
class Transaction(models.Model):
    written_datetime = models.DateTimeField(auto_now_add=True) #작성일
    updated_datetime = models.DateTimeField(auto_now=True) #작성 날짜
    transaction_time = models.DateTimeField()
    transaction_from = models.ForeignKey(Financialaccount,on_delete=models.CASCADE,related_name='transaction',blank=True,null=True)
    transaction_from_card = models.ForeignKey(Cardaccount,on_delete=models.CASCADE,related_name='transaction',blank=True,null=True)
    transaction_to_name = models.ForeignKey('Company_Category_Correlation',on_delete=models.CASCADE,related_name='transaction', default ="현금",blank=True,null=True)
    deposit_amount = models.IntegerField(default=0)
    withdrawal_amount = models.IntegerField(default=0)
    main_category = models.CharField(max_length=250, default='미지정')
    sub_category = models.ManyToManyField("Tag_Category", blank=True, related_name='transaction',)
    # category_hooked = models.ForeignKey('Main_Category',on_delete=models.CASCADE,related_name='hookedtransaction',blank=True,null=True)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return str(self.transaction_time.strftime("%Y-%m-%d %H Hour")) +'|from: ' + str(self.transaction_from) + '|to: ' + str(self.transaction_to_name)
#항목 통합
class Main_Category(models.Model):
    flow_category = models.CharField(max_length=50)
    main_category = models.CharField(max_length=50)
    
    def __str__(self):
        return self.flow_category + " : " + self.main_category

class Tag_Category(models.Model):
    # upper_clas_category = models.ForeignKey("Main_Category", on_delete=models.CASCADE, verbose_name="category_id" ,related_name="sub_category")
    sub_category = models.CharField(max_length=50, unique=True, primary_key=True)
    
    def __str__(self):
        return self.sub_category
    
class Company_Category_Correlation(models.Model):
    company_accountname = models.CharField(max_length=250, unique=True, primary_key=True)
    company_commonname = models.CharField(max_length=250, blank=True)
    category_hook = models.ForeignKey("Main_Category", on_delete=models.CASCADE, verbose_name="category_id" ,related_name="hooked_company", blank=True, null=True)
    
    def __str__(self):
        return  self.company_accountname + " : " + self.company_commonname
# #소비 항목
# class Cosume_category(models.Model):
#     main_category = models.CharField(max_length=50)
#     sub_category = models.CharField(max_length=50)
# #소득 항목
# class Income_category(models.Model):
#     main_category = models.CharField(max_length=50)
#     sub_category = models.CharField(max_length=50)   
    
    
    