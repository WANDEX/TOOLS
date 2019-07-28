#!/bin/sh
anbox-bridge &&
anbox session-manager --gles-driver=host &
anbox launch --package=org.anbox.appmgr --component=org.anbox.appmgr.AppViewActivity

