from django.contrib.auth.models import User
from django.db.models.signals import post_migrate
from django.dispatch import receiver

@receiver(post_migrate)
def create_initial_data(sender, **kwargs):
    if sender.name == 'temp_admin':  # Replace 'your_app_name' with the name of your app
        admin_username = 'admin'
        admin_password = '1234'  # Change this to a secure password
        
        # Check if the 'admin' user already exists
        if not User.objects.filter(username=admin_username).exists():
            user = User.objects.create_superuser(admin_username, '', admin_password)
            # user.is_superuser = True
            # user.is_staff = True
            # user.save()
            print(f'Superuser created successfully!')