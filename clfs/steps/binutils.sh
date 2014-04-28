#!/bin/bash


download()
{
	wget -N http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2 -P ${CLFS_DISTFILES_DIR}
}

unpack()
{
	rm -rf binutils-2.23.2
	tar xvjpf ${CLFS_DISTFILES_DIR}/binutils-2.23.2.tar.bz2 -C ./
}


configure()
{
	rm -rf binutils-build
	mkdir -pv binutils-build

	cd binutils-build/

	../binutils-2.23.2/configure \
		--prefix=/usr \
		--target=${CLFS_TARGET} \
		--with-sysroot=${CLFS_SYSROOT_PREFIX} \
		--disable-werror

#		--disable-nls \
#		--disable-multilib
}

build()
{
	cd binutils-build/

	make
}

install()
{
	rm -rf install_prefix
	mkdir install_prefix

	cd binutils-build/

	make install DESTDIR=${STEP_BUILD_DIR}/install_prefix
}

filter()
{
	rm -rf filtered_prefix
#	mkdir filtered_prefix
	cp -av install_prefix filtered_prefix
	rm -rfv filtered_prefix/usr/{info,lib,man,share}
}

merge()
{
	cp -av ./filtered_prefix/usr/* ${CLFS_CROSSTOOLS_PREFIX}/
}

__cmd_list=(
	download
	unpack
	configure
	build
	install
	filter
	merge
)



