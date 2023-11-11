@echo off
call mysql -u adminF -p0223 -e "CREATE DATABASE IF NOT EXISTS %1;"