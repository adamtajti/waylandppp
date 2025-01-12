#!/usr/bin/env bash

# The purpose of this script is to filter those unstable protocol versions,
# which are already available in the stable branch.
#
# This is needed because the compilation of the unstable library depends on
# the stable one and if the scanner generates compilation unit from both
# of these XMLs, then there will be redefinition errors.
#
# Usage: find-unique-unstable-protocols.sh <path-to-unstable-folder>

if [ "$#" -ne 1 ]; then
  echo "usage: find-unique-unstable-protocols.sh <path-to-unstable-folder>"
  echo "example: find-unique-unstable-protocols.sh /usr/share/wayland-protocols/unstable/"
  exit 1
fi

path_to_unstable_folder="$1"
path_to_stable_folder="$(cd "$1/../stable/" && pwd)"
paths_to_print_at_the_end=""

for unstable_protocol_folder_path in "$path_to_unstable_folder"/*; do
  unstable_protocol_folder_name="$(basename "$unstable_protocol_folder_path")"

  # skip this folder if there is a matching stable protocol
  for stable_protocol_folder_path in "$path_to_stable_folder"/*; do
    stable_protocol_folder_name="$(basename "$stable_protocol_folder_path")"

    if [ "$unstable_protocol_folder_name" = "$stable_protocol_folder_name" ]; then
      # echo "$unstable_protocol_folder_name = $stable_protocol_folder_name"
      continue 2
    fi
  done

  paths_to_print_at_the_end+="$(find "$unstable_protocol_folder_path"/*)\n"
done

echo -e "$paths_to_print_at_the_end"
