#!/bin/bash



download()
{
	wget -N http://www.musl-libc.org/releases/musl-0.9.14.tar.gz -P ${CLFS_DISTFILES_DIR}

}

unpack()
{
	rm -rf musl-0.9.14

	tar xvzpf ${CLFS_DISTFILES_DIR}/musl-0.9.14.tar.gz -C ./
}


configure()
{
	cd musl-0.9.14

	CC=${CLFS_TARGET}-gcc ./configure \
		--prefix=/ \
		--target=${CLFS_TARGET}
}

build()
{
	cd musl-0.9.14

	CC=${CLFS_TARGET}-gcc make
}

install()
{
	rm -rf install_prefix
	mkdir -p install_prefix
	cd musl-0.9.14

	DESTDIR=${CLFS_BUILD_DIR}/libc/install_prefix make install
}

merge()
{
	cp ./install_prefix/* -rv ${CLFS_SYSROOT_PREFIX}/
}

__cmd_list=(
        download
        unpack
        configure
        build
	install
	merge
)



