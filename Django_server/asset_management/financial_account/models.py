from django.db import models

# Create your models here.
class Financialaccount(models.Model):
    nickname = models.CharField(max_length=250)
    bankname = models.CharField(max_length=20)
    accountnumber= models.CharField(max_length=100, unique=True)
    assetamount = models.IntegerField()
    
    
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
    
class Payaccount(models.Model):
    nickname = models.CharField(max_length=250)
    corpname = models.CharField(max_length=20)
    assetamount = models.IntegerField()
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.nickname
    
    
class Cardaccount(models.Model):
    nickname = models.CharField(max_length=250)
    corpname = models.CharField(max_length=20)
    bankconnect = models.ForeignKey('Financialaccount', on_delete=models.CASCADE)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.nickname
    