@echo off

call C:\Users\USER\anaconda3\Scripts\activate.bat
call cd D:\Program development\�ڻ�_�м�_��\Django_server\asset_management_aws
call python manage.py makemigrations
choice /c YN /m "Press Y to continue or N to exit"
if errorlevel 2 exit
call python manage.py migrate
pause
@REM start python manage.py runserver 
start C:\Users\USER\anaconda3\Scripts\activate.bat