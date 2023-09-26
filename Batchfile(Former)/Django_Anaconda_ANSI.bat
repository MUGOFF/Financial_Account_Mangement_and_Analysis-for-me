@echo off

call C:\Users\USER\anaconda3\Scripts\activate.bat
call cd D:\Program development\자산_분석_툴\Django_server\asset_management
call python manage.py makemigrations
call python manage.py migrate
start python manage.py runserver 
start C:\Users\USER\anaconda3\Scripts\activate.bat