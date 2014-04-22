#!/bin/bash




download()
{
	wget -N ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.7.3/gcc-4.7.3.tar.bz2 -P ${CLFS_DISTFILES_DIR}
	wget -N http://patches.cross-lfs.org/embedded-dev/gcc-4.7.3-musl-1.patch -P ${CLFS_DISTFILES_DIR}
	wget -N http://gforge.inria.fr/frs/download.php/32210/mpfr-3.1.2.tar.bz2 -P ${CLFS_DISTFILES_DIR}
	wget -N http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz -P ${CLFS_DISTFILES_DIR}
	wget -N http://ftp.gnu.org/gnu/gmp/gmp-5.1.2.tar.bz2 -P ${CLFS_DISTFILES_DIR}

}

unpack()
{
	rm -rf gcc-4.7.3

	tar xvjpf ${CLFS_DISTFILES_DIR}/gcc-4.7.3.tar.bz2 -C ./

	tar xvjpf ${CLFS_DISTFILES_DIR}/mpfr-3.1.2.tar.bz2 -C ./
	tar xvjpf ${CLFS_DISTFILES_DIR}/gmp-5.1.2.tar.bz2 -C ./
	tar xvzpf ${CLFS_DISTFILES_DIR}/mpc-1.0.1.tar.gz -C ./

	cd gcc-4.7.3/
	mv -v ../mpfr-3.1.2 mpfr
	mv -v ../gmp-5.1.2 gmp
	mv -v ../mpc-1.0.1 mpc

}

patch_step()
{
	cd gcc-4.7.3/

	patch -Np1 -i ${CLFS_DISTFILES_DIR}/gcc-4.7.3-musl-1.patch
}

configure()
{
	rm -rf gcc-build
	mkdir -p gcc-build
	cd gcc-build

	../gcc-4.7.3/configure \
		--prefix=${CLFS_BUILD_DIR}/gcc_static/install_prefix \
		--build=${CLFS_HOST} \
		--host=${CLFS_HOST} \
		--target=${CLFS_TARGET} \
		--with-sysroot=${CLFS_SYSROOT_PREFIX} \
		--disable-nls \
		--disable-shared \
		--without-headers \
		--with-newlib \
		--disable-decimal-float \
		--disable-libgomp \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libatomic \
		--disable-libquadmath \
		--disable-threads \
		--enable-languages=c \
		--disable-multilib \
		--with-mpfr-include=$(pwd)/../gcc-4.7.3/mpfr/src \
		--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
		--with-arch=${CLFS_ARM_ARCH} \
		--with-float=${CLFS_FLOAT} \
		--with-fpu=${CLFS_FPU}
}

build()
{
	cd gcc-build

	make all-gcc all-target-libgcc
}

install()
{
	rm -rf install_prefix
	mkdir -p install_prefix
	cd gcc-build

	make install-gcc install-target-libgcc
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

