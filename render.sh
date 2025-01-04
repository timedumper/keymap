#!/usr/bin/env bash

script_dir=$(cd "$(dirname "$0")" && pwd)
script_fn=$(basename "$0")
keymap_yml=$script_dir/keymap.yml
draw_cfg_yml=$script_dir/draw-config.yml
out_dir=$script_dir/renders
dry_run=false

cmd=render

multiple_files_mode=false
render_all_layers=false
open_files_in_browser=false

layers=()
output_fn=

existing_layers=()
layers_to_render=()

is_keymap_refresh() {
  [[ $KEYMAP_REFRESH == 1 ]]
}

parse_args() {
  while arg=$1; shift; do
    case $arg in
      -w|--watch) 
        if ! is_keymap_refresh; then
          cmd=watch
        fi
        ;;
      -o) 
        output_fn=$1; shift
        if [[ -z $output_fn || $output_fn == -* ]]; then
          echo "Option '-o' requires an argument: filename"
          exit 1
        fi
        ;;
      -m) multiple_files_mode=true;;
      -b|--browser) 
        if ! is_keymap_refresh; then
          open_files_in_browser=true
        fi
        ;;
      -h|--help) 
        print_help
        exit 0
        ;;
      -*) echo "Unsupported command: $arg";;
      *) layers+=("$arg")
    esac
  done

  if [[ ${#layers} -eq 0 ]]; then
    render_all_layers=true
  fi
}

# Reads existing layer names from the keymap config into global `existing_layers` array.
read_existing_layers() {
  if [[ ${#existing_layers} -ne 0 ]]; then
    return
  fi

  for ln in $(cat "$keymap_yml" | grep -E '^\s+[A-Z0-9_-]+:' | cut -d : -f 1); do 
    existing_layers+=("$ln")
  done
  
  echo "Found ${#existing_layers} layers."
}

# Verifies requested layers (from global `layers` var) exist and replace 
# them with their canonical names.
lookup_and_verify_layers() {
  echo "Verify requested layers exist..."

  local req_layers=()

  for cli_ln in "${layers[@]}"; do
    local found=false

    for real_ln in "${existing_layers[@]}"; do 
      if [[ ${real_ln,,} == ${cli_ln,,} ]]; then
        found=true
        req_layers+=("$real_ln")
        break;
      fi
    done

    if ! $found; then
      echo -n "Layer: '$cli_ln' not found in keymap, available layers are:"
      printf " %s" "${existing_layers[@]}"
      exit 1
    fi
  done

  layers=( "${req_layers[@]}" )
}

get_outfn_prefix() {
  local outfn_minus_ext=

  if $multiple_files_mode; then
    if [[ -z $output_fn ]]; then
      outfn_minus_ext=$script_dir/renders/layer-
    else
      outfn_minus_ext=${output_fn%.svg}
    fi
  else
    if [[ -z $output_fn ]]; then
      outfn_minus_ext=$script_dir/renders/keymap
    else
      outfn_minus_ext=${output_fn%.svg}
    fi
  fi

  printf '%s' "$outfn_minus_ext"
}

populate_layers_to_render() {
  if $render_all_layers; then
    layers_to_render=()
    for ln in "${existing_layers[@]}"; do
      if ! [[ $ln == *DUMMY* ]]; then
        layers_to_render+=("$ln")
      fi
    done
  else
    layers_to_render=("${layers[@]}")
  fi
}

render() {
  local outfn_minus_ext=$(get_outfn_prefix)

  # declare -p outfn_minus_ext

  if $multiple_files_mode; then
    for ln in "${layers_to_render[@]}"; do
      local fn=$outfn_minus_ext$ln.svg
      echo Rendering "$ln" to "$fn"
      do_render "$fn" "$ln"
    done
  else
    echo "Rendering layers ${layers_to_render[*]} into a single file."
    do_render "$outfn_minus_ext.svg" "${layers_to_render[@]}"
  fi
}

open_rendered_files() {
  local outfn_minus_ext=$(get_outfn_prefix)

  if $multiple_files_mode; then
    for ln in "${layers_to_render[@]}"; do
      local full_fn=$(readlink -f "$outfn_minus_ext$ln.svg")
      open_in_browser "$full_fn"
    done
  else
    open_in_browser "$outfn_minus_ext.svg"
  fi
}

open_in_browser() {
  local fn=$1

  if [[ -f $fn ]]; then
    echo "Opening $fn in a browser..."
    open "file://$(readlink -f "$fn")"
  else
    echo "Can't open file $fn in a browser (no such file)"
  fi
}

# Renders keymap into a file.
# Arguments:
#   1) output filename
#   2...) zero or more layer names to render where zero means "render all"
do_render() {
  local out_fn=$1; shift;
  local layers=( "$@" )

  local -a cmd=(keymap -c "$draw_cfg_yml" draw "$keymap_yml" -o "$out_fn" $(
      if [[ ${#layers} -gt 0 ]]; then
        printf -- "-s"
        printf " %s" "${layers[@]}"
      fi
    )
  )

  if $dry_run; then
    printf "[%s]" "${cmd[@]}"
    echo
  else
    # set -x
    "${cmd[@]}"
    # set +x
  fi
}

watch() {
  echo
  echo "Watching changes in:"
  echo " - $draw_cfg_yml"
  echo " - $keymap_yml"
  echo

  printf "%s\n" "$draw_cfg_yml" "$keymap_yml" | entr -p /usr/bin/env KEYMAP_REFRESH=1 bash "$0" "$@"
}

print_help() {
  cat <<HELP
Usage: $script_fn [options] [layerA, layerB, ...]"

Positional arguments:
  layerXXX   Names of the layers to include into the output. By default, all non-dummy layers 
             are included.

Options:
  -o            Filename where to render the keymap to (or prefix for individual layer files)
  -m            Render each layer into individual file
  -w, --watch   Render everything as usual, but then:
                  1. open all output file in a browser
                  2. watch the input files and rerender everything if they change
  -b, --browser Automatically open each rendered file in a browser (for -w this is only done
                once before start of monitoring files for changes)
HELP
}

if is_keymap_refresh; then
  echo ------------------------------------------------------------------------------
  echo ">> $(date): one or more input files have changed, rerendering..."
  echo ------------------------------------------------------------------------------
fi

parse_args "$@"
read_existing_layers
lookup_and_verify_layers
populate_layers_to_render

case $cmd in
  render) 
    render
    if $open_files_in_browser; then
      open_rendered_files
    fi
    ;; 
  watch) 
    render
    if $open_files_in_browser; then
      open_rendered_files
    fi
    watch "$@"
    ;;
esac
