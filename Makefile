ARCH			:=arm
CROSS_COMPILE	:=aarch64-none-linux-gnu-
DEFCONFIG		:=u_boot_explorer_defconfig
BUILD_BASE		:=$(PWD)/build
U_BOOT_DIR		:=$(BUILD_BASE)/u-boot
U_BOOT_SRC		:=u-boot

QEMU			:=qemu-system-aarch64
MACHINE			:=virt
CPU				:=cortex-a53
MEMORY			:=1G
ELF_IMAGE		:=$(U_BOOT_DIR)/u-boot
QFLAGS			:=-nographic -monitor null -net nic -net user
NVME_IMAGE		:=nvme.img
NVME_BS			:=512
NVME_COUNT		:=16M

all: build

phony+=defconfig
defconfig:
	$(MAKE) -C $(U_BOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(U_BOOT_DIR) $(DEFCONFIG)

phony+=menuconfig
menuconfig:
	$(MAKE) -C $(U_BOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(U_BOOT_DIR) menuconfig

phony+=build
build: defconfig
	$(MAKE) -C $(U_BOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(U_BOOT_DIR) -j 4

phony+=clean
clean:
	$(MAKE) -C $(U_BOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(U_BOOT_DIR) clean

phony+=distclean
distclean:
	$(MAKE) -C $(U_BOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(U_BOOT_DIR) distclean

phony+=run
run:
	$(QEMU) -M $(MACHINE),virtualization=true,gic-version=3 \
	-cpu $(CPU) -m $(MEMORY) \
	-kernel $(ELF_IMAGE) \
	-drive file=$(NVME_IMAGE),if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm \
	$(QFLAGS)

phony+=debug
debug:
	$(QEMU) -M $(MACHINE),virtualization=true,gic-version=3 \
	-cpu $(CPU) -m $(MEMORY) \
	-kernel $(ELF_IMAGE) \
	-drive file=$(NVME_IMAGE),if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm \
	$(QFLAGS) -S -gdb tcp::9500,ipv4

phony+=genimage
genimage:
	./genimage.sh

.PHONY: $(phony)