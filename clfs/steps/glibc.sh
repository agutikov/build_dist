#!/bin/bash





download()
{
	wget -N http://ftp.gnu.org/gnu/libc/glibc-2.12.2.tar.bz2 -P ${CLFS_DISTFILES_DIR}
	wget -N http://ftp.gnu.org/gnu/libc/glibc-ports-2.12.1.tar.bz2 ${CLFS_DISTFILES_DIR}
}

unpack()
{
	rm -rf glibc-2.12.2

	tar xvjpf ${CLFS_DISTFILES_DIR}/glibc-2.12.2.tar.bz2 -C ./
	tar xvjpf ${CLFS_DISTFILES_DIR}/glibc-ports-2.12.1.tar.bz2 -C ./
}

ports()
{
	cp -av glibc-ports-2.12.1/* glibc-2.12.2/
}

configure()
{
	rm -rf glibc-build
	mkdir -p glibc-build

	cd glibc-build

	../glibc-2.12.2/configure \
		--host=$CLFS_TARGET \
		--prefix=/usr \
		--with-headers=${CLFS_SYSROOT_PREFIX}/usr/include \
		--without-cvs
}

build()
{
	cd glibc-build

	make
}

install()
{
	rm -rf install_prefix
	mkdir -p install_prefix
	cd glibc-build

	make install install_root=${STEP_BUILD_DIR}/install_prefix
}

merge()
{
	cp -av ./install_prefix/* ${CLFS_SYSROOT_PREFIX}/
}

__cmd_list=(
	download
	unpack
	ports
	configure
	build
	install
	merge
)



