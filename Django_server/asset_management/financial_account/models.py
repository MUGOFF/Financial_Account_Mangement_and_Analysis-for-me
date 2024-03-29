from django.db import models
import uuid
from datetime import date
from django.contrib.auth.models import User
# Create your models here.
class Financialaccount(models.Model):
    id = models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True)
    # user_connector = models.ForeignKey()
    accountnumber= models.CharField(max_length=100) #1
    nickname = models.CharField(max_length=250) #2
    bankname = models.CharField(max_length=20) #3
    account_type = models.CharField(max_length=50, default="입출금계좌") #4
    account_founddate = models.DateField(default=date(2016,1,1)) #5
    account_expireddate = models.DateField(blank=True, null=True) #6
    account_balance = models.IntegerField(default=0) #7
    description = models.TextField(blank=True, default="") #8
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='Account_ownership', default=1) #9,default='admin'
    
    
    def __str__(self):
        return self.nickname
# class Bankaccount(models.Model):
#     nickname = models.CharField(max_length=250)
#     bankname = models.CharField(max_length=20)
#     accountnumber= models.CharField(max_length=100, unique=True)
#     assetamount = models.IntegerField()
    
    
#     def __str__(self):
#         return self.nickname
    
    
# class Securitiesaccount(models.Model):
#     nickname = models.CharField(max_length=250)
#     corpname = models.CharField(max_length=20)
#     accountnumber= models.CharField(max_length=100, unique=True)
#     assetamount = models.IntegerField()
    
#     def __str__(self):
#         return self.nickname
class Cardaccount(models.Model):
    id = models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True)
    cardnumber = models.CharField(max_length=50)
    nickname = models.CharField(max_length=250)
    corpname = models.CharField(max_length=20)
    card_type = models.CharField(max_length=50, default="체크카드")
    bankconnect = models.ForeignKey(Financialaccount, on_delete=models.CASCADE, related_name='connectcard', null=True, blank=True)
    expiredmonth = models.DateField(default=date.today)
    description = models.TextField(blank=True)
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='Card_ownership', default=1)
    
    def __str__(self):
        return self.nickname
    
class Payaccount(models.Model):
    nickname = models.CharField(max_length=250)
    corpname = models.CharField(max_length=20)
    assetamount = models.IntegerField(default=0)
    description = models.TextField(blank=True)
    bankconnection = models.ManyToManyField('Financialaccount', related_name='connectpay', blank=True)
    cardconnection = models.ManyToManyField('Cardaccount', related_name='connectpay', blank=True)
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='Payment_ownership', default=1)
    
    def __str__(self):
        return self.nickname
    
    
    