#!/bin/bash

set -o errexit

# https://bjornjohansen.no/encrypt-file-using-ssh-key

# PASSWORD_ENC generated once with
# openssl rand 32 | openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f ~/.ssh/id_rsa.pub -m PKCS8) | base64 --wrap=0
PASSWORD_ENC=XwH9JDk0QBH3WO09r7g+/nzU+ypn51/bpconrGDTq94ydSu1D7dTxD7fZwfSTf+iVdd6OmKqXsPWQNH1EGxRbNf8QV+jBGVPTG56WgHAix3gTOpKnn9gMvKvpPu3AEeE9Tyzdl7s1SxeIwlNkLQR/LjllCDKmyJIuacalk/B5qwo5mgCpzArG1UPQEYaEGekL+Gd0p0CejtZlX7YX8VKTC41WN3DqRQ/HUA9dFqWlv3iM1uwQOLWc42cL3xNH/yTUan1IWJWzgyNsvsbB+YeigF7dnG942jSUSvqDYS8MDRIo13KVLLz3A9FI8bcyyC7uRJ/T3HxFBl1ru7nLOGP2Q==

function crypt {
  openssl aes-256-cbc -md sha256 -pass "pass:$(echo $PASSWORD_ENC | base64 --decode | openssl rsautl -decrypt -oaep -inkey ~/.ssh/id_rsa)" "$@"
}

function ensure {
  local NAME=$1
  local NAME_ENC=$1.enc
  grep "^/$NAME$" .gitignore >/dev/null || echo "/$NAME" >>.gitignore
  if [ -f $NAME ]
  then
    if ! ([ -f $NAME_ENC ] && diff $NAME <(crypt -d -in $NAME_ENC) >/dev/null)
    then
      echo "Encrypting $NAME"
      crypt -in $NAME -out $NAME_ENC
    fi
  else
    if [ -f $NAME_ENC ]
    then
      echo "Decrypting $NAME_ENC"
      crypt -d -in $NAME_ENC -out $NAME
    else
      echo "No plain or encrypted file to ensure $NAME"
      exit 1
    fi
  fi
}

ensure secrets.auto.tfvars
