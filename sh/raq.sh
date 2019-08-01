#!/bin/sh
#qemu-system-x86_64 -m 4G -boot d -cpu host -smp 4 -machine type=q35,accel=kvm -net nic -net user,hostfwd=tcp::4444-:5555 -hda android.img -usb -device usb-tablet -display sdl -vga std -soundhw all -audiodev id=pa,driver=pa,server=unix:/run/user/1000/pulse/native,out.name=combined
qemu-system-x86_64 -m 4G -boot d -cpu host -smp 4 -machine type=q35,accel=kvm -net nic -net user,hostfwd=tcp::4444-:5555 -hda /var/lib/libvirt/images/android.qcow2 -usb -device usb-tablet
