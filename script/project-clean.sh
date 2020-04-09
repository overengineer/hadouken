#!/usr/bin/env bash

# cpp project build script
# author: Mustafa Kemal GILOR <mgilor@nettsi.com>

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Relative paths
declare -A RP
# Common headers
source $SCRIPT_ROOT/common.sh && hadouken.define_relative_paths $SCRIPT_ROOT RP

if [ "$#" -ge 1 ]; then
  case $1 in
    -d|--deep)
      git -C ${RP["PROJECT"]} clean -fxd
    ;;
  esac
else
  if [ -d "${RP["BUILD"]}" ]; then
    echo "Erasing ${RP["BUILD"]} (recursive)"
    rm -rf ${RP["BUILD"]}
  else
      echo "nothing to clean."
  fi
fi

