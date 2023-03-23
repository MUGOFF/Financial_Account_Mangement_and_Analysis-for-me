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
    transaction_to_name = models.CharField(max_length=250)
    transaction_to_nickname = models.CharField(max_length=250)
    changed_amount = models.IntegerField(default=0)
    main_category = models.CharField(max_length=250)
    sub_category = models.CharField(max_length=250)
    category_hooked = models.ForeignKey('Flow_category',on_delete=models.CASCADE,related_name='hookedtransaction',blank=True,null=True)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return str(self.transaction_time.strftime("%Y-%m-%d %H Hour")) +'|from: ' + str(self.transaction_from) + '|to: ' + self.transaction_to_nickname
#항목 통합
class Flow_category(models.Model):
    flow_category = models.CharField(max_length=50)
    main_category = models.CharField(max_length=50)
    sub_category = models.CharField(max_length=50)
# #소비 항목
# class Cosume_category(models.Model):
#     main_category = models.CharField(max_length=50)
#     sub_category = models.CharField(max_length=50)
# #소득 항목
# class Income_category(models.Model):
#     main_category = models.CharField(max_length=50)
#     sub_category = models.CharField(max_length=50)   
    
    
    