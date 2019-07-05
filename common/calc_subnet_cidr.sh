#!/bin/bash

SUBNET='0.253.253.192'

octet2dec() {
  local IFS=.
  set -- $1
  echo $((($1 << 24) | ($2 << 16) | ($3 << 8) | $4))
}

dec2octet() {
  printf '%d.%d.%d.%d\n' $(($1 >> 24)) $(($1 >> 16 & 0xFF)) $(($1 >> 8 & 0xFF)) $(($1 & 0xFF))
}

calc_subnet() {
  local IFS=/
  set -- $1
  vpc=$(octet2dec $1)
  mask=$((2 ** (32 - $2) - 1))
  echo $(($(octet2dec $SUBNET) & $mask | $vpc))
}

vpc_cidr=$(cut -d '"' -f 4)
printf '{"subnet_cidr":"%s"}' "$(dec2octet $(calc_subnet $vpc_cidr))/25"

