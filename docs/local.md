## 

```shell script

docker run -itd --name=vulsdb --net=host \
  --restart=always \
    -v /srv/docker/mysql/vulsdata:/var/lib/mysql \
    -v $(pwd)/docs/mysql.conf.d:/etc/mysql/docs/mysql.conf.d \
    -e MYSQL_USER=vuls \
    -e MYSQL_PASSWORD=vulspa55 \
    -e MYSQL_DATABASE=default_db \
    -e MYSQL_ROOT_PASSWORD=vulspa55 \
    mysql:5.7
    
# 10.0.11.36
# exploitdb 导入
docker run --rm -it \
    vuls/go-exploitdb \
    fetch exploitdb  --dbtype mysql --dbpath "root:vulspa55@tcp(10.0.11.36:3306)/vuls_exploit?parseTime=true"

# CVE 
for i in `seq 2010 $(date +"%Y")`; do \
    docker run --rm -it \
    vuls/go-cve-dictionary fetchnvd \
    --dbtype mysql --dbpath "root:vulspa55@tcp(10.0.11.36:3306)/vuls_cve?parseTime=true" \
    -years $i; 
done

for i in `seq 2010 $(date +"%Y")`; do \
    docker run --rm -it \
    vuls/go-cve-dictionary fetchjvn \
    --dbtype mysql --dbpath "root:vulspa55@tcp(10.0.11.36:3306)/vuls_cve?parseTime=true" \
    -years $i;
done

# gost
docker run --rm -it \
		-v ${PWD}:/vuls \
		vuls/gost \
		fetch redhat --dbtype mysql --dbpath \
		 "root:vulspa55@tcp(10.0.11.36:3306)/vuls_gost?parseTime=true";
		
		
docker run --rm -it \
		-v ${PWD}:/vuls \
		vuls/gost \
		fetch debian --dbtype mysql --dbpath \
		 "root:vulspa55@tcp(10.0.11.36:3306)/vuls_gost?parseTime=true";
			
## Oval

docker run --rm -it \
  vuls/goval-dictionary \
  fetch-redhat --dbtype mysql \
  --dbpath "root:vulspa55@tcp(10.0.11.36:3306)/vuls_goval?parseTime=true" \
  6 7 8;		

docker run --rm -it \
  vuls/goval-dictionary \
  fetch-debian --dbtype mysql \
  --dbpath "root:vulspa55@tcp(10.0.11.36:3306)/vuls_goval?parseTime=true" \
  8 9 10;	

docker run --rm -it \
  vuls/goval-dictionary \
  fetch-ubuntu --dbtype mysql \
  --dbpath "root:vulspa55@tcp(10.0.11.36:3306)/vuls_goval?parseTime=true" \
  14 16 18 19;	

docker run --rm -it  vuls/goval-dictionary \
  fetch-amazon --dbtype mysql --dbpath \
   "root:vulspa55@tcp(10.0.11.36:3306)/vuls_goval?parseTime=true";


docker run --rm -it vuls/goval-dictionary fetch-alpine --dbtype mysql --dbpath \
	"root:vulspa55@tcp(10.0.11.36:3306)/vuls_goval?parseTime=true" \
	3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10

    
```