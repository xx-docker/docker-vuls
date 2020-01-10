#!/bin/sh

docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-cve-dictionary

for i in `seq 2002 $(date +"%Y")`; do \
    docker run --rm -it \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-cve-dictionary fetchnvd -years $i; \
done

for i in `seq 1998 $(date +"%Y")`; do \
    docker run --rm -it \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:go-cve-dictionary fetchjvn -years $i; \
done
