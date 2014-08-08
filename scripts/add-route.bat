@echo off
echo Adding the following route entry to your local route table to enable direct warden container access. You may have to run this in a command prompt with elevated administrator privileges.
echo   - route add 10.244.0.0/19 192.168.50.4
echo.
route add 10.244.0.0/19 192.168.50.4
