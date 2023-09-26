@echo off
setlocal enabledelayedexpansion
set DB_NAME=%1
cd /d "D:\Program development\Git Repo\Financial_Account_Mangement_and_Analysis-for-me\Django_server"

REM Start your Django server script (replace with the actual script name)
call C:\Users\USER\anaconda3\Scripts\activate.bat

REM Update the settings.py file with the new database name
python -c "import os; os.environ['DJANGO_SETTINGS_MODULE'] = 'your_project_name.settings'; from django.conf import settings; settings.DATABASES['default']['NAME'] = '!DB_NAME!'; from django.core.management import call_command; call_command('migrate', interactive=False)"

call python manage.py makemigrations
call python manage.py migrate
REM Create a superuser (optional)
@REM python manage.py createsuperuser --username=admin --password=admin@example.com --noinput

REM Start Django server
start "Django server" python manage.py runserver
