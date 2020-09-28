# MEMO

### before everything else
cd to root project dir

## main
### create a patch
create a patch from difference in original and modified file with diff,\
and output into a file as a unified context:
```sh
diff -up config.h config_new.h > patch/st-colemak.diff
diff -up ../dmenu-5.0/dmenu.c ./dmenu.c > ./patch/5.0/dmenu-fix_make_warning_INTERSECT-5.0.diff
diff -up ../dmenu-5.0/ ./ > ./patch/5.0/dmenu-password_4.9FIX-5.0.diff
```

### how to patch
```sh
patch < ./patch/st-colemak.diff
```

### how to reverse patch changes (undo the patch)
```sh
patch -R < ./patch/st-colemak.diff
```

## if troubles

### check out rejected hunks file
```sh
vim *.rej
```

### get original file before patches
```sh
vim *.orig
```
