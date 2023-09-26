@echo off
setlocal enabledelayedexpansion
set DB_NAME=%1
cd /d "path_to_your_django_project"

REM Update the settings.py file with the new database name
python -c "import os; os.environ['DJANGO_SETTINGS_MODULE'] = 'your_project_name.settings'; from django.conf import settings; settings.DATABASES['default']['NAME'] = '!DB_NAME!'; from django.core.management import call_command; call_command('migrate', interactive=False)"

REM Create a superuser (optional)
python manage.py createsuperuser --username=admin --email=admin@example.com --noinput

REM Start Django server
start "Django server" python manage.py runserver
