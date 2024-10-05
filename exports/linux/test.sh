#!/bin/sh
echo -ne '\033c\033]0;tiny-creatures\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/test.x86_64" "$@"
