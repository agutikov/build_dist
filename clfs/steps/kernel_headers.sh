#!/bin/bash


download()
{
	wget -N http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.0.80.tar.bz2 -P ${CLFS_DISTFILES_DIR}
}

unpack()
{
	rm -rf linux-3.0.80
	tar xvjpf ${CLFS_DISTFILES_DIR}/linux-3.0.80.tar.bz2 -C ./
}

install()
{
	rm -rf install_prefix
	mkdir install_prefix
	cd linux-3.0.80/
	make mrproper
	make ARCH=${CLFS_ARCH} headers_check
	make ARCH=${CLFS_ARCH} INSTALL_HDR_PATH=../install_prefix headers_install
}

merge()
{
	cp ./install_prefix/* -rv ${CLFS_SYSROOT_PREFIX}/
}

__cmd_list=(
        download
        unpack
	install
	merge
)



