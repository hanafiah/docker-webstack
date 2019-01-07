Docker Web Stack
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

## SubModule project
if you're using git for your projects. you can add that under projects folder using submodule command

```
cd projects
git submodule add -f git@github.com:hanafiah/example.git 
```

Virtual host
===
make sure to set virtual host on hosts file
## Mac/Linux
```
sudo vim /etc/hosts
```
## windows
1. open notepad as administratio
2. open hosts file located at
```
C:\Windows\System32\drivers\etc\hosts
```

add the following
```
127.0.0.1 www.example.local
```

once saved, you should be able to access site from

http://www.example.local

Load Example
===
run the following command
```
git submodule update --init 
```

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



Using php composer
===
https://github.com/hanafiah/docker-webstack/wiki/How-to-use-composer
