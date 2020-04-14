#!/bin/sh
## to get btn_codes: $evtest /dev/input/by-id/*
## defender game racer turbo
#--force-feedback --rumble 255,255 --test-rumble \
xboxdrv --evdev /dev/input/by-id/usb-0810_USB_Gamepad-event-joystick \
--axismap -Y1=Y1,-Y2=Y2 \
--evdev-absmap ABS_X=X1,ABS_Y=Y1,ABS_RZ=X2,ABS_Z=Y2,ABS_HAT0X=DPAD_X,ABS_HAT0Y=DPAD_Y \
--evdev-keymap BTN_BASE4=Start,BTN_BASE3=Back,BTN_THUMB2=A,BTN_THUMB=B,BTN_TOP=X,BTN_TRIGGER=Y,BTN_BASE=LB,BTN_BASE2=RB,BTN_TOP2=LT,BTN_PINKIE=RT,BTN_BASE5=TL,BTN_BASE6=TR \
--mimic-xpad --silent
#--mimic-xpad
