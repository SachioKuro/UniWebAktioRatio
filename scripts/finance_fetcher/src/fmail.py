#!/usr/bin/python
import smtplib
import sys

fromaddr = 'sb.code@mail.de'
toaddrs  = sys.args[1]
msg = 'Your Stock [' + sys.args[2] + '] exceeded your limit [' + sys.args[3] + '-' + sys.args[4] + '] with a value of ' + sys.args[5] + '!'


# Credentials (if needed)
username = 'sb.code@mail.de'
password = 'KitA2407!'

# The actual mail send
server = smtplib.SMTP(host='smtp.mail.de', port=587)
server.starttls()
server.login(username,password)
server.sendmail(fromaddr, toaddrs, msg)
server.quit()
