#!/bin/bash

echo "Loading SPL to the device"
sudo sunxi-fel spl sunxi-spl.bin
sleep 1

echo "Uploadnig padded SPL to device memory"
sudo sunxi-fel write 0x43000000 sunxi-spl-with-ecc.bin

echo "Uploading padded Uboot to device memory"
sudo sunxi-fel write 0x4a000000 padded_uboot

echo "Uploading Uboot flashing script image to device memory"
sudo sunxi-fel write 0x43100000 uboot-script.img

echo "Running Uboot with flashing script on device and  waiting for fastboot"
sudo sunxi-fel exe 0x4a000000

timeout=60
while let "timeout > 0"; do
  test -n "$(fastboot -i 0x1f3a devices)" && break
  let timeout--
  sleep 1
done
let timeout==0 &&{
  echo "cannot find device in fastboot mode"
  exit -1
}
echo "Flashing UBI image using fastboot"
sudo fastboot -i 0x1f3a -u flash UBI ubi.img.sparse

echo "Flashing done, hopefully now the device will boot correctly to Arch"
sudo fastboot -i 0x1f3a continue
