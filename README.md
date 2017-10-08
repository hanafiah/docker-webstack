Docker General Stack
===============================

This is general stack for the web development environment with preset Nginx, PHP, MariaDB & MongoDB

You can use this setup for multiple projects. 

Put in your project under projects folder and set your nginx.conf there.

Structure
===
```
Projects\YOUR_PROJECT_FOLDER\nginx.conf
```

Please see the example project on how to configure your nginx.conf file
[projects/example](https://github.com/hanafiah/docker-general/tree/master/projects/example)

To Start Docker
===
run the following command inside your docker-general directory
```
docker-compose up -d
```

To stop
```
docker-compose stop
```

![Alt text](/screen1.png)
