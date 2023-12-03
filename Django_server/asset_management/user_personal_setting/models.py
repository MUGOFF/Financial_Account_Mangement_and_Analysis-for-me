from django.db import models
from django.contrib.auth.models import User


# Create your models here.        

class MonthlyBudgetSetting(models.Model):
    year = models.IntegerField()
    month = models.IntegerField()
    json_string = models.TextField(blank=True)
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='MonthlyBookSetting_ownership', default=1) #9,default='admin'
    
    def __str__(self):
        return str(self.owner) + ":"+ str(self.year)+ "/" + str(self.month)
    
class Company_Category_Correlation(models.Model):
    company_accountname = models.CharField(max_length=250, unique=True, primary_key=True)
    company_commonname = models.CharField(max_length=250, blank=True)
    category_hook = models.ForeignKey("Main_Category", on_delete=models.CASCADE, verbose_name="category_id" ,related_name="hooked_company", blank=True, null=True)
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='CompanyNickNameBookSetting_ownership', default=1) #9,default='admin'
    
    def __str__(self):
        return  str(self.owner) + ";"+ self.company_accountname + " : " + self.company_commonname
    
class Main_Category(models.Model):
    flow_category = models.CharField(max_length=50)
    main_category = models.CharField(max_length=50)
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='CategorySetting_ownership', default=1) #9,default='admin'
    
    def __str__(self):
        return self.flow_category + " : " + self.main_category
