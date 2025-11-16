if test "${boot_target}" = "mmc0" || test "${boot_target}" = "mmc1" ; then
   if test -e ${devtype} ${devnum}:${distro_bootpart} /image.ub; then
      fatload ${devtype} ${devnum}:${distro_bootpart} 0x10000000 image.ub;
      bootm 0x10000000;
      exit;
   fi
   if test -e ${devtype} ${devnum}:${distro_bootpart} /Image; then
      fatload ${devtype} ${devnum}:${distro_bootpart} 0x00200000 Image;;
   fi
   if test -e ${devtype} ${devnum}:${distro_bootpart} /system.dtb; then
      fatload ${devtype} ${devnum}:${distro_bootpart} 0x00100000 system.dtb;
   fi
   if test -e ${devtype} ${devnum}:${distro_bootpart} /rootfs.cpio.gz.u-boot; then
      fatload ${devtype} ${devnum}:${distro_bootpart} 0x04000000 rootfs.cpio.gz.u-boot;
      booti 0x00200000 0x04000000 0x00100000
      exit;
   fi
   booti 0x00200000 - 0x00100000
   exit;
fi
