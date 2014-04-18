#!/bin/bash


export CLFS_SCRIPTS_DIR=$(readlink -f .)

export CLFS_DISTFILES_DIR=${CLFS_SCRIPTS_DIR}/distfiles
export CLFS_WORK_DIR=${CLFS_SCRIPTS_DIR}/work
	export CLFS_CROSSTOOLS_PREFIX=${CLFS_WORK_DIR}/cross-tools
	export CLFS_SYSROOT_PREFIX=${CLFS_WORK_DIR}/sysroot
	export CLFS_BUILD_DIR=${CLFS_WORK_DIR}/build
	export CLFS_TARGET_ROOTFS=${CLFS_WORK_DIR}/rootfs


unset CFLAGS
unset CXXFLAGS

export CLFS_FLOAT=soft
export CLFS_FPU=
export CLFS_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
export CLFS_TARGET=arm-softfloat-linux-gnueabi
export CLFS_ARCH=arm
export CLFS_ARM_ARCH=armv6



export steps=(
"kernel_headers"

"binutils"
"gcc_static"
"libc"
"gcc_final"

"rootfs_layout"

"switch_toolchain"

"busybox"
"iana-etc"

"linux_kernel"

)




