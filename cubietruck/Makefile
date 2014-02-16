
OUTPUT_TMP_ROOTFS=../../_root

INSTALL_SD_DEV=/dev/sdb

INSTALL_NFS_ROOT=../../nfs/cubietruck_debug_rootfs
NFS_ROOT=/var/nfs/cubietruck_debug_rootfs
TFTP_PATH=/var/tftp/

KERNEL_SRC_DIR=../../linux-sunxi
U-BOOT_SRC_DIR=../../u-boot-sunxi

SUNXI_TOOLS_DIR=../../sunxi-tools
FEX2BIN=$(SUNXI_TOOLS_DIR)/fex2bin

BOOT_CMD=boot.cmd
FEX=cubietruck.fex
KERNEL_CONFIG=cubietruck_config

ROOTFS_TAR=../../stage3-armv7a_hardfp-20140112.tar.bz2

ARCH=arm
CROSS_COMPILE=armv7a-hardfloat-linux-gnueabi-

ENV= ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)


.PHONY: install_nfs install_tftp install_sd_u-boot install_tmp install
.PHONY: clean all help menuconfig uImage modules modules_instal u-boot

help:
	@echo "Usable targets:"
	@echo "    all:                build kernel, modules, u-boot, script.bin and boot.scr"
	@echo "    install:            install to nfs, tftp and temporary rootfs"
	@echo "    install_nfs:        install modules to nfs"
	@echo "    install_tftp:       copy kernel to tftp"
	@echo "    u-boot:             build u-boot"
	@echo "    install_sd_u-boot:  dd u-boot image to " $(INSTALL_SD_DEV)
	@echo "    menuconfig:         menuconfig in kernel dir and copy .config back"
	@echo "    uImage:             build uImage"
	@echo "    modules:            build modules"
	@echo "    modules_install:    install modules to temporary rootfs" $(OUTPUT_TMP_ROOTFS)

all: u-boot uImage modules boot.scr script.bin

clean:
	rm -f boot.scr script.bin
	rm -rf $(OUTPUT_TMP_ROOTFS)

####### directories ############################################################

$(OUTPUT_TMP_ROOTFS):
	mkdir -p $(OUTPUT_TMP_ROOTFS)

$(OUTPUT_TMP_ROOTFS)/boot: $(OUTPUT_TMP_ROOTFS)
	mkdir -p $@

$(INSTALL_NFS_ROOT):
	mkdir -p $@

####### Installation ###########################################################

install: install_tmp install_nfs install_tftp

install_tmp: $(OUTPUT_TMP_ROOTFS)/uImage modules_install boot.scr script.bin
	cp boot.scr  $(OUTPUT_TMP_ROOTFS)/boot/
	cp script.bin $(OUTPUT_TMP_ROOTFS)/boot/

install_nfs: $(KERNEL_SRC_DIR) $(INSTALL_NFS_ROOT)
	make $(ENV) -C $(KERNEL_SRC_DIR) modules_install INSTALL_MOD_PATH=$(INSTALL_NFS_ROOT)

install_tftp: $(KERNEL_SRC_DIR)/arch/arm/boot/uImage $(TFTP_PATH)
	cp $< $(TFTP_PATH)/

$(OUTPUT_TMP_ROOTFS)/uImage: $(KERNEL_SRC_DIR)/arch/arm/boot/uImage $(OUTPUT_TMP_ROOTFS)
	cp $< $@

####### U-Boot #################################################################

u-boot:
	make $(ENV) -C $(U-BOOT_SRC_DIR)/ cubietruck

$(U-BOOT_SRC_DIR)/u-boot-sunxi-with-spl.bin:
	make $(ENV) -C $(U-BOOT_SRC_DIR)/ cubietruck

install_sd_u-boot: $(INSTALL_SD_DEV) $(U-BOOT_SRC_DIR)/u-boot-sunxi-with-spl.bin
	sudo dd if=$(U-BOOT_SRC_DIR)/u-boot-sunxi-with-spl.bin of=$(INSTALL_SD_DEV) bs=1024 seek=8

####### Linux Kernel ###########################################################

menuconfig: $(KERNEL_CONFIG) $(KERNEL_SRC_DIR)
	cp $(KERNEL_CONFIG) $(KERNEL_SRC_DIR)/.config
	make $(ENV) -C $(KERNEL_SRC_DIR) menuconfig
	cp $(KERNEL_SRC_DIR)/.config $(KERNEL_CONFIG)

$(KERNEL_SRC_DIR)/.config: $(KERNEL_SRC_DIR)
	cp $(KERNEL_CONFIG) $(KERNEL_SRC_DIR)/.config

uImage: $(KERNEL_SRC_DIR)/.config
	make $(ENV) -C $(KERNEL_SRC_DIR) uImage -j5

$(KERNEL_SRC_DIR)/arch/arm/boot/uImage: $(KERNEL_SRC_DIR)/.config
	make $(ENV) -C $(KERNEL_SRC_DIR) uImage -j5

modules: $(KERNEL_SRC_DIR)/.config
	make $(ENV) -C $(KERNEL_SRC_DIR) modules -j5

modules_install: $(KERNEL_SRC_DIR)/.config $(OUTPUT_TMP_ROOTFS)
	make $(ENV) -C $(KERNEL_SRC_DIR) modules_install INSTALL_MOD_PATH=$(OUTPUT_TMP_ROOTFS)

####### scripts ################################################################

boot.scr: boot.cmd
	mkimage -C none -A arm -T script -d boot.cmd boot.scr

script.bin: $(FEX) $(FEX2BIN)
	$(FEX2BIN) $< $@

$(FEX2BIN): $(SUNXI_TOOLS_DIR)
	make -C $< fex2bin



