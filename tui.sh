#!/bin/sh

#docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vuls

docker run --rm -it\
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vuls tui $@ \
    -log-dir=/vuls/log \
    -config=/vuls/config.toml\
    -refresh-cve \
    $@

