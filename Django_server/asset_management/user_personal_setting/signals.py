# from django.contrib.auth.models import User
# from django.db.models.signals import post_migrate
# from django.dispatch import receiver

# @receiver(post_migrate)
# def create_initial_data(sender, **kwargs):
#     if sender.name == 'temp_admin':  # Replace 'your_app_name' with the name of your app
#         admin_username = 'admin'
#         admin_password = '1234'  # Change this to a secure password
        
#         # Check if the 'admin' user already exists
#         if not User.objects.filter(username=admin_username).exists():
#             user = User.objects.create_superuser(admin_username, '', admin_password)
#             # user.is_superuser = True
#             # user.is_staff = True
#             # user.save()
#             print(f'Superuser created successfully!')
            
# from django.db.models.signals import post_save
from django.dispatch import receiver
from djoser.signals import user_registered
from django.contrib.auth.models import User
from user_personal_setting.models import *

@receiver(user_registered)
def create_user_models(sender, user, request, **kwargs):
    if not user.is_staff:
        # Create a MonthlyBudgetSetting instance for the non-staff user
        MonthlyBudgetSetting.objects.create(owner=user)
        
        # Create a Company_Category_Correlation instance for the non-staff user
        # Company_Category_Correlation.objects.create(owner=user, company_accountname='Default Company Name')
        
        # Create a CategorySetting instance for the non-staff user
        CategorySetting.objects.create(owner=user)