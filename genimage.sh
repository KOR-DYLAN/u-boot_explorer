#!/bin/bash
echo rm -f nvme.img
rm -f nvme.img

echo create 4GB fat image...
sudo dd if=/dev/zero of=fat.img bs=512 count=8M status=progress
sudo chown $USER:$USER fat.img
mkfs.vfat -F 32 -I fat.img

echo copy files to fat.img...
echo mcopy -s -i fat.img Makefile ::/ 
mcopy -s -i fat.img Makefile ::/ 
echo mcopy -s -i fat.img build/* ::/ 
mcopy -s -i fat.img build/u-boot ::/ 

echo create mbr...
sudo dd if=/dev/zero of=mbr.img bs=512 count=2048 status=progress
sudo chown $USER:$USER mbr.img

cat mbr.img fat.img > nvme.img
echo -e "o\nn\np\n1\n2048\n\nw" | fdisk nvme.img

echo rm -f fat.img mbr.img
rm -f fat.img mbr.img