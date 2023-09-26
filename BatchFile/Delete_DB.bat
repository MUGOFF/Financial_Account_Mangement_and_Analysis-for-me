@echo off
mysql -u your_username -pyour_password -e "DROP DATABASE IF EXISTS %1;"
