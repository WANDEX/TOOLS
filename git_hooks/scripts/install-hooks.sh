#!/bin/sh

GIT_DIR="$(git rev-parse --git-dir)"

echo "Installing hooks..."
# this command creates symlink to our pre-push script
ln -s ../../scripts/hooks/pre-push-readme-usage "$GIT_DIR"/hooks/pre-push
echo "Done!"
