#!/bin/sh
# must be run with root privileges to access hardware acceleration
qemu-system-x86_64 -m 4G -boot d -cpu host -smp 4 -machine type=q35,accel=kvm -net nic -net user,hostfwd=tcp::4444-:5555 \
    -hda ~/Downloads/android.img -usb -device usb-tablet -display sdl -vga std \
    -audiodev pa,id=hda,out.format=f32,out.frequency=48000,out.name=combined,server=/run/user/1000/pulse/native, \
    -device intel-hda -device hda-output,audiodev=hda
