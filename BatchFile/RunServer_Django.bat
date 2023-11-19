@echo off
setlocal enabledelayedexpansion
set DB_NAME=%1

@REM Start your Django server script (replace with the actual script name)
call C:\Users\USER\anaconda3\Scripts\activate.bat

@REM Update the settings.py file with the new database name
cd /d "D:\Program development\Git Repo\Financial_Account_Mangement_and_Analysis-for-me\BatchFile"
call python Update_DB.py !DB_NAME!
@REM REM Update the settings.py file with the new database name
@REM python -c "import os; os.environ['DJANGO_SETTINGS_MODULE'] = 'asset_management.settings'; from django.conf import settings; settings.DATABASES['default']['NAME'] = '!DB_NAME!'; from django.core.management import call_command; call_command('migrate', interactive=False)"

cd /d "D:\Program development\Git Repo\Financial_Account_Mangement_and_Analysis-for-me\Django_server\asset_management"
@REM Create a superuser (optional)
@REM python manage.py createsuperuser --username=admin --password=0000 --noinput
call python manage.py makemigrations
call python manage.py migrate

@REM Start Django server
start "Django server Volatile" python manage.py runserver

@REM export DJANGO_SUPERUSER_PASSWORD=edroth0116
call python manage.py createsuperuser --username=admin --email=admin@example.com 