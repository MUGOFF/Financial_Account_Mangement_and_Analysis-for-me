@REM @echo off
call cd D:\Program development\자산_분석_툴\VUE_client\manual_project
Start npm run serve
timeout 3
Start chrome http://localhost:8080/
call C:\Users\USER\anaconda3\Scripts\activate.bat
call cd D:\Program development\자산_분석_툴\Django_server\asset_management
call python manage.py makemigrations
call python manage.py migrate
start python manage.py runserver 
timeout 3
start chrome http://localhost:8000/