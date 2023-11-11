@echo off
call mysql -u adminF -p0223 -e "DROP DATABASE IF EXISTS %1;"
