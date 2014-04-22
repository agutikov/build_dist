#!/bin/bash


download()
{
	wget -N http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2 -P ${CLFS_DISTFILES_DIR}
	wget -N http://patches.cross-lfs.org/embedded-dev/binutils-2.23.2-musl-1.patch -P ${CLFS_DISTFILES_DIR}
}

unpack()
{
	rm -rf binutils-2.23.2
	tar xvjpf ${CLFS_DISTFILES_DIR}/binutils-2.23.2.tar.bz2 -C ./
}

patch_step()
{
	cd binutils-2.23.2/
	patch -Np1 -i ${CLFS_DISTFILES_DIR}/binutils-2.23.2-musl-1.patch
}

configure()
{
	rm -rf binutils-build
	mkdir -pv binutils-build
	cd binutils-build/

	../binutils-2.23.2/configure \
		--prefix=${CLFS_BUILD_DIR}/binutils/install_prefix \
		--target=${CLFS_TARGET} \
		--with-sysroot=${CLFS_SYSROOT_PREFIX} \
		--disable-nls \
		--disable-multilib
}

build()
{
	cd binutils-build/
	make configure-host
	make

}

install()
{
	rm -rf install_prefix
	mkdir install_prefix
	cd binutils-build/
	make install
}

merge()
{
	cp ./install_prefix/* -rv ${CLFS_CROSSTOOLS_PREFIX}/
}

__cmd_list=(
        download
        unpack
        patch_step
        configure
        build
	install
	merge
)



