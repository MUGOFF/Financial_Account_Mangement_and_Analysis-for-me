from django.db import models


# Create your models here.        
class MonthlyBookSetting(models.Model):
    year = models.IntegerField()
    month = models.IntegerField()
    json_string = models.TextField(blank=True)
    
    def __str__(self):
        return str(self.json_string) + "/"+ str(self.year)+ "/" + str(self.month)