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
- **ERROR:**
  - 当前并没有进入到 `mysql` 

## Step4 开始格式化数据库
```shell script
chmod -R 755 . 
bash ./update.sh 

```

**自己动手一步步搭建** 
- 略 --> 参考最后面的一步步运行和排查


## Step5 开始根据配置文件扫描
```shell script
./scan.sh 

```

## Step6 查看报告
```shell script

./report.sh 
```

## 部署界面
```shell script
docker run -itd --name=vulrepo \
  -p 5111:5111 \
  -v /etc/localtime:/etc/localtime:ro \
  -v $(pwd):/vuls \
  -v $(pwd)/results:/vuls/results/ \
  -v $(pwd)/vuls_logs:/var/log/vuls \
  registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vulrepo  

```



## 异常修复相关；
> 一步步运行和问题排查
```shell script

docker run -itd --name=vulsdb -p 33306:3306 \
  --restart=always \
    -v /srv/docker/mysql/vulsdata:/var/lib/mysql \
    -v $(pwd)/docs/mysql.conf.d:/etc/mysql/docs/mysql.conf.d
    -e MYSQL_USER=vuls \
    -e MYSQL_PASSWORD=vulspa55 \
    -e MYSQL_DATABASE=default_db \
    -e MYSQL_ROOT_PASSWORD=vulspa55 \
    registry.cn-hangzhou.aliyuncs.com/xxzhang/mysql:5.7 
    
docker exec -t vulsdb mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_cve` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
docker exec -t vulsdb mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_goval` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
docker exec -t vulsdb mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_gost` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
docker exec -t vulsdb mysql -uroot -pvulspa55 -e 'CREATE DATABASE `vuls_exploit` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'


# exploitdb 导入
docker run --rm -it \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-exploitdb \
    fetch exploitdb  --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_exploit?parseTime=true"

# CVE 
for i in `seq 2010 $(date +"%Y")`; do \
    docker run --rm -it \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-cve-dictionary fetchnvd -years $i \
    --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_cve?parseTime=true"; 
done

for i in `seq 2010 $(date +"%Y")`; do \
    docker run --rm -it \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-cve-dictionary fetchjvn -years $i \
    --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_cve?parseTime=true";
done

# gost
docker run --rm -it \
		-v ${PWD}:/vuls \
		registry.cn-chengdu.aliyuncs.com/rapid7/vuls:gost \
		fetch redhat --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_gost?parseTime=true";
		
		
docker run --rm -it \
		-v ${PWD}:/vuls \
		registry.cn-chengdu.aliyuncs.com/rapid7/vuls:gost \
		fetch debian --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_gost?parseTime=true";
			
## Oval

docker run --rm -it \
  registry.cn-chengdu.aliyuncs.com/rapid7/vuls:goval-dictionary \
  fetch-redhat --dbtype mysql \
  --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_goval?parseTime=true" \
  6 7 8;		

docker run --rm -it \
  registry.cn-chengdu.aliyuncs.com/rapid7/vuls:goval-dictionary \
  fetch-debian --dbtype mysql \
  --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_goval?parseTime=true" \
  8 9 10;	

docker run --rm -it \
  registry.cn-chengdu.aliyuncs.com/rapid7/vuls:goval-dictionary \
  fetch-ubuntu --dbtype mysql \
  --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_goval?parseTime=true" \
  14 16 18 19;	

docker run --rm -it  registry.cn-chengdu.aliyuncs.com/rapid7/vuls:goval-dictionary \
  fetch-amazon --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_goval?parseTime=true";


docker run --rm -it registry.cn-chengdu.aliyuncs.com/rapid7/vuls:goval-dictionary fetch-alpine --dbtype mysql --dbpath "root:vulspa55@tcp(172.31.26.99:33306)/vuls_goval?parseTime=true" 3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10

```

## 重要执行的参考
- https://vuls.io/docs/en/usage-configtest.html