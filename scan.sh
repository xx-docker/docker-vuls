#!/bin/sh

#docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vuls

docker run --rm -it\
    -v $HOME/.ssh:/root/.ssh:ro \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vuls configtest \
    -log-dir=/vuls/log \
    -config=/vuls/config.toml \
    $@ 

ret=$?
if [ $ret -ne 0 ]; then
	exit 1
fi

docker run --rm -it\
    -v $HOME/.ssh:/root/.ssh:ro \
    -v $PWD:/vuls \
    registry.cn-chengdu.aliyuncs.com/rapid7/vuls:vuls scan \
    -log-dir=/vuls/log \
    -config=/vuls/config.toml \
    $@ 

