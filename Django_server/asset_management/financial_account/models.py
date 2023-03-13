from django.db import models

# Create your models here.
class Financialaccount(models.Model):
    nickname = models.CharField(max_length=250)
    bankname = models.CharField(max_length=20)
    accountnumber= models.CharField(max_length=100, unique=True, primary_key=True)
    account_type = models.CharField(max_length=50, default="입출금계좌")
    assetamount = models.IntegerField(default=0)
    description = models.TextField(blank=True, default="")
    
    
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
    nickname = models.CharField(max_length=250)
    corpname = models.CharField(max_length=20)
    cardnumber = models.CharField(max_length=50, unique=True, primary_key=True)
    card_type = models.CharField(max_length=50, default="체크카드")
    bankconnect = models.ForeignKey(Financialaccount, on_delete=models.CASCADE, related_name='connectcard', null=True, blank=True)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.nickname
    
class Payaccount(models.Model):
    nickname = models.CharField(max_length=250)
    corpname = models.CharField(max_length=20)
    assetamount = models.IntegerField(default=0)
    description = models.TextField(blank=True)
    bankconnection = models.ManyToManyField('Financialaccount', related_name='connectpay')
    cardconnection = models.ManyToManyField('Cardaccount', related_name='connectpay')
    
    def __str__(self):
        return self.nickname
    
    
    