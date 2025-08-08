#!/usr/bin/expect -f
set timeout 10

spawn /oas/AdminCreate
expect "Enter username:"
send "${OAS_ADMIN_USER}\r"
expect "Enter password:"
send "${OAS_ADMIN_PASSWORD}\r"
expect eof
