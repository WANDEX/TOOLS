# custom git hooks

## MEMO
```bash
cp scripts/ project_root_destination/

# symlink one of the hooks or use script for it
./scripts/install-hooks.sh

# dont forget to tweak hook for specific project

# dont forget to make scripts executable
chmod +x script_name
```

###### Skipping hook flag:
```bash
git {commit/push} --no-verify
```

###### Did not tested that.
To easily execute a command in your submodule root, under [alias] in your .gitconfig, add:
```bash
[alias]
    sh = "!f() { root=$(pwd)/ && cd ${root%%/.git/*} && git rev-parse && exec \"$@\"; }; f"

# This allows you to easily do things like:
git sh ag <string>

# ??? WTF ???
```

