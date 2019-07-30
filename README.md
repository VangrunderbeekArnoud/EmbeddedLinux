# Embedded Linux

* Bootloader
* Kernel
* Root Filesystem
* System applications
* Device-specific data

## Bootloader

The bootloader is the first piece of code to run when the processor is powered up. The way the processor locates the bootloader is very device specific, but in most cases there is only one such location, and so there can only be one bootloader. If there is no backup, updating the bootloader is risky: what happens if the system powers down midway? Consequently, most update solutions leave the bootloader alone. This is not a big problem, because the bootloader only runs for a short time at power-on and is not normally a great source of runtime bugs.

## Kernel

The Linux kernel is a critical component that will certainly need updating from time to time. There are several parts to the kernel:
* A binary image loaded by the bootloader, often stored in the root filesystem. 
* Many devices also have a **Device Tree Binary (DTB)** that describes hardware to the kernel, and so has to be updated in tandem. The DTB is usually stored alongside the kernel binary.
* There may be kernel modules in the root filesystem.
The kernel and DTB may be stored in the root filesystem, so long as the bootloader has the ability to read that filesystem format, or it may be in a dedicated partition. In either case, it is possible to have redundant copies.

## Root filesystem

The root filesystem contains the essential system libraries, utilities, and scripts needed to make the system work. It is very desirable to be able to replace and upgrade all of these. The mechanism depends on the implementation. Common formats for embedded root file systems are:
* Ramdisk, loaded from raw flash memory or a disk image at boot. To update it, you just need to overwrite the ramdisk image and reboot.
* Read-only compressed filesystems, such as *squashfs*, stored in a slash partition. Since these types of filesystem do not implement a write function, the only way to update is to write a complete filesystem image to the partition.
* Normal filesystem types. For raw flash memory, JFFS2 and UBIFS formats are common, and for managed flash memory, such as eMMC and SD cards, the format is likely to be ext4 or F2FS. Since these are writable at runtime, it is possible to update them file by file.

## System applications

The system applications are the main payload of the device; they implement its primary function. As such, they are likely to be updated frequently to fix bugs and to add features. They may be bundled with the root filesystem, but it is also common for them to be placed in a separate filesystem to make updating easier and to maintain separation between the system files, which are usually open source, and the application files, which are often proprietary.

## Device-specific data

This is the combination of files that are modified ar runtime, and includes configuration settings, logs, user-supplied data, and the like. It is not often that they need to be updated, but they do need to be preserved during an update. Such data needs to be stored in a partition of its own.
