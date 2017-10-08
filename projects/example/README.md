Docker General Stack
===============================

This example shows you how to set nginx.conf for your project's server block

Change the following line on nginx.conf for your project.
```
server_name EXAMPLE.local;
root        /var/www/projects/EXAMPLE;
    
access_log  /var/www/projects/logs/EXAMPLE-access.log;
error_log   /var/www/projects/logs/EXAMPLE-error.log;
```

make sure to add the following line in your `/etc/hosts` file on Linux/Mac or `C:\Windows\System32\Drivers\etc\hosts` on WIndows
```
127.0.0.1 EXAMPLE.local
```

once you add that, you can access this page by the following url http://example.local


