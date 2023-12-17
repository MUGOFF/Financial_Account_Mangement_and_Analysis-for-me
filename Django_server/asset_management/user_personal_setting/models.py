from django.db import models
from django.contrib.auth.models import User
import json

# Create your models here.        

Budget_default = {"default": {}, "list_set": []} 
class MonthlyBudgetSetting(models.Model):
    budget_json_string = models.TextField(default=json.dumps(Budget_default))
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='MonthlyBookSetting_ownership', default=1) #9,default='admin'
    # year = models.IntegerField()
    # month = models.IntegerField()
    
    def __str__(self):
        return str(self.owner) + "예산 설정"
    
class Company_Category_Correlation(models.Model):
    company_accountname = models.CharField(max_length=250, unique=True, primary_key=True)
    company_commonname = models.CharField(max_length=250, blank=True)
    # category_hook = models.ForeignKey("Main_Category", on_delete=models.CASCADE, verbose_name="category_id" ,related_name="hooked_company", blank=True, null=True)
    category_hook = models.CharField(max_length=250, blank=True, null=True)
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='CompanyNickNameBookSetting_ownership', default=1) #9,default='admin'
    
    def __str__(self):
        return  str(self.owner) + ";"+ self.company_accountname + " : " + self.company_commonname


Category_default = {"수입":["급여소득", "용돈", "금융소득"], "소비":["식비","주거비","통신비","생활비","미용비","의료비","문화비","교통비","세금","카드대금","보험","기타",], "이체":["내계좌이체", "계좌이체", "저축", "투자"]} 
class CategorySetting(models.Model):
    category_json_string = models.TextField(default=json.dumps(Category_default))
    owner = models.ForeignKey(User,on_delete=models.CASCADE,related_name='CategorySetting_ownership', default=1) #9,default='admin'
    
    def __str__(self):
        return str(self.owner) + "카테고리 설정"
