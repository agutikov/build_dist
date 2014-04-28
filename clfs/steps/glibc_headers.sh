#!/bin/bash



download()
{
	wget -N http://ftp.gnu.org/gnu/libc/glibc-2.12.2.tar.bz2 -P ${CLFS_DISTFILES_DIR}
	wget -N http://ftp.gnu.org/gnu/libc/glibc-ports-2.12.1.tar.bz2 ${CLFS_DISTFILES_DIR}
	ls -la ${CLFS_DISTFILES_DIR}/glibc-2.12.2-patches-4.tar.bz2
}

unpack()
{
	rm -rf glibc-2.12.2
	rm -rf glibc-ports-2.12.1
	rm -rf glibc-2.12.2-patches-4

	tar xvjpf ${CLFS_DISTFILES_DIR}/glibc-2.12.2.tar.bz2 -C ./
	tar xvjpf ${CLFS_DISTFILES_DIR}/glibc-ports-2.12.1.tar.bz2 -C ./

	mkdir -pv glibc-2.12.2-patches-4
	tar xvjpf ${CLFS_DISTFILES_DIR}/glibc-2.12.2-patches-4.tar.bz2 -C ./glibc-2.12.2-patches-4/
}

ports()
{
	cp -av glibc-ports-2.12.1/* glibc-2.12.2/
}

patch_step()
{
	cp -av glibc-2.12.2-patches-4/extra/* glibc-2.12.2/
	cd glibc-2.12.2/
	for f in ../glibc-2.12.2-patches-4/patches/*.patch
	do
		echo "Applying "$f
		patch -p1 -i $f
	done
}

configure()
{
	rm -rf glibc_headers-build
	mkdir -p glibc_headers-build

	cd glibc_headers-build

	../glibc-2.12.2/configure \
		--host=$CLFS_TARGET \
		--prefix=/usr \
		--with-headers=${CLFS_SYSROOT_PREFIX}/usr/include \
		--without-cvs \
		--disable-sanity-checks
}

install()
{
	rm -rf install_prefix
	mkdir -p install_prefix
	cd glibc_headers-build

	make install-headers install_root=${STEP_BUILD_DIR}/install_prefix
}

after_install()
{
	mkdir -p install_prefix/usr/include/gnu
	touch install_prefix/usr/include/gnu/stubs.h
	cp glibc-2.12.2/bits/stdio_lim.h install_prefix/usr/include/bits/
}

merge()
{
	cp -av ./install_prefix/* ${CLFS_SYSROOT_PREFIX}/
}

__cmd_list=(
	download
	unpack
	ports
	patch_step
	configure
	install
	after_install
	merge
)



