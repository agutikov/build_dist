#!/bin/bash


download()
{
	ls -la ${CLFS_DISTFILES_DIR}/linux_kernel-git-latest.tar.gz
}

unpack()
{
	rm -rf linux_kernel-git-latest
	tar xvzpf ${CLFS_DISTFILES_DIR}/linux_kernel-git-latest.tar.gz -C ./
}

configure()
{
	cd linux_kernel-git-latest
	make ARCH=${CLFS_ARCH} ${KERNEL_DEFCONFIG}
}

install()
{
	rm -rf install_prefix
	mkdir install_prefix

	cd linux_kernel-git-latest/

	make ARCH=${CLFS_ARCH} headers_check
	make ARCH=${CLFS_ARCH} INSTALL_HDR_PATH=${STEP_BUILD_DIR}/install_prefix/usr headers_install
}

merge()
{
	cp -av ./install_prefix/* ${CLFS_SYSROOT_PREFIX}/
}

__cmd_list=(
	download
	unpack
	configure
	install
	merge
)



