@REM @echo off
call cd D:\Program development\�ڻ�_�м�_��\VUE_client\manual_project
Start npm run serve
timeout 3
Start chrome http://localhost:8080/
call C:\Users\USER\anaconda3\Scripts\activate.bat
call cd D:\Program development\�ڻ�_�м�_��\Django_server\asset_management
call python manage.py makemigrations
call python manage.py migrate
start python manage.py runserver 
timeout 3
start chrome http://localhost:8000/