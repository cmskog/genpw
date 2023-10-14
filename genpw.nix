{ coreutils, writeShellScriptBin, xclip } :
writeShellScriptBin
  "genpw"
  ''
  PATH=
  set -euo pipefail
  shopt -s shift_verbose

  unset DELETE_ALL_EXCEPT

  if [[ $# -ge 1 ]]
  then
    if [[ $1 == -b ]]
    then
      # AWS bucket names: lowercase letters, numbers, dots (.), and hyphens (-).
      DELETE_ALL_EXCEPT="[:lower:][:digit:].-"
    elif [[ $1 == -h ]]
    then
      DELETE_ALL_EXCEPT="[:xdigit:]"
    elif [[ $1 == -n ]]
    then
      DELETE_ALL_EXCEPT="[:digit:]"
    elif [[ $1 == -s ]]
    then
      DELETE_ALL_EXCEPT="[:print:]"
    fi

    if [[ ''${DELETE_ALL_EXCEPT:-} ]]
    then
      shift
    fi
  fi

  : ''${DELETE_ALL_EXCEPT:="[:graph:]"}

  if [[ $# == 1 && $1 =~ ^[0-9]+$ && $1 -gt 0 ]]
  then
    PWLEN=$1
  else
    echo "Usage: $0 [-b | -h | -n | -s] <password length>"
    exit 1
  fi

  {
    ${coreutils}/bin/cat /dev/urandom || :
  } \
  | \
  {
    ${coreutils}/bin/tr -dc "$DELETE_ALL_EXCEPT" || :
  } \
  | \
  ${coreutils}/bin/head -c $PWLEN \
  | \
  ${xclip}/bin/xclip -i -sel p

  echo "Generated password: '$(${xclip}/bin/xclip -o -sel p)'"
  ''
