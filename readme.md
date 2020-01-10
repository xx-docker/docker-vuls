# Docker-vuls 部署

> if you aren't chinese, you can jump to
> [https://github.com/vulsio/vulsctl](https://github.com/vulsio/vulsctl)
> which will help you more and run better.

--------------------------------------------------------

# GFW 内往下看
- imgs 里面记录 

## Step1 拷贝出国内的镜像
> 全部来自于官方，如果不可信，自己看 imgs 构建对应的文件即可。

```shell script

docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-cve-dictionary 
docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-exploitdb
docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:goval-dictionary
docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vulrepo  
docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vuls  
docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:gost   

```

## Step 2 安装 mysql 
> 如果不信任，自己去构建 `FROM mysql:5.7`
```shell script
docker run -itd --name=mysql --net=host --restart=always \
    -v /srv/docker/data/mysqldata:/var/lib/mysql \
    -e MYSQL_USER=vuls \
    -e MYSQL_PASSWORD=vulspa55 \
    -e MYSQL_DATABASE=default_db \
    -e MYSQL_ROOT_PASSWORD=vulspa55 \
    -e character-set-server=utf8 \
    -e collation-server=utf8_general_ci \
    registry.cn-hangzhou.aliyuncs.com/xxzhang/mysql:5.7 
```
**初始化数据库**

```shell script
docker exec -t mysql mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_cve` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
docker exec -t mysql mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_goval` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
docker exec -t mysql mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_gost` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
docker exec -t mysql mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_exploit` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
```

## Step3 修改 `config.toml`
> 这个步骤的目的是，将数据存储到 `mysql` 而不是 `sqllite` 
- 注意修改对应的下面的内容为自己的连接
```
type = "mysql"
url = "root:vulspa55@tcp(127.0.0.1:3306)/vuls_gost?parseTime=true"
```

## Step4 开始格式化数据库
```shell script

```

