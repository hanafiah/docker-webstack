Docker General Stack
===============================

This is example shows you how to set nginx.conf for your project's server block

Change the following for line on nginx.conf for your project.
```
server_name EXAMPLE.local;
root        /var/www/projects/EXAMPLE;
    
access_log  /var/www/projects/logs/EXAMPLE-access.log;
error_log   /var/www/projects/logs/EXAMPLE-error.log;
```

make sure to add the following line in your /etc/hosts file
```
127.0.0.1 example.local
```

once you add that, you can access this page by the following url http://example.local


