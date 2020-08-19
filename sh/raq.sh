#!/bin/sh
# must be run with root privileges to access hardware acceleration
qemu-system-x86_64 -m 4G -boot d -cpu host -smp 4 -machine type=q35,accel=kvm -net nic -net user,hostfwd=tcp::4444-:5555 \
    -hda ~/Downloads/android.img -usb -device usb-tablet -vga std -display sdl,gl=on \
    -audiodev pa,id=snd0,out.format=f32,out.frequency=48000,out.buffer-length=50000,out.stream-name=combined,out.name=combined,server=/run/user/1000/pulse/native, \
    -device ich9-intel-hda -device hda-output,audiodev=snd0

