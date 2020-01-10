#! /bin/sh -

if [ $# -eq 0 ]; then
	echo "specify [--redhat --debian]"
	exit 1
fi

target=$1
shift

# docker pull registry.cn-chengdu.aliyuncs.com/rapid7/vuls:gost

case "$target" in
	--redhat) docker run --rm -it \
		-v ${PWD}:/vuls \
		registry.cn-chengdu.aliyuncs.com/rapid7/vuls:gost fetch ${@} redhat
		;;
	--debian) docker run --rm -it \
		-v ${PWD}:/vuls \
		registry.cn-chengdu.aliyuncs.com/rapid7/vuls:gost fetch ${@} debian
		;;
	--*)  echo "specify [--redhat --debian]"
		exit 1
	    ;;
	*) echo "specify [--redhat --debian]"
		exit 1
	    ;;
esac

exit 0

