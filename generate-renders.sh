#!/usr/bin/env bash 

script_dir=$(cd "$(dirname "$0")" && pwd)

./render.sh -m -o "$script_dir/renders/layer-"
