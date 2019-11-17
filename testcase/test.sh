#!/usr/bin/env bash

set -e

function rand() {
  echo "ibase=16; "$(xxd -ps -u -l 8 /dev/urandom) | bc
}

if [ $# -ne 0 ]; then
  SEED="$1"
else
  SEED=$(rand)
fi

echo "Seed: $SEED"

ASM=$(mktemp --suffix=.s)
HEX=$(mktemp)
INS=$(mktemp)
RES1=$(mktemp)
RES2=$(mktemp)

make > /dev/null 2> /dev/null
./generate_rand_insr "$SEED" > "$ASM"
yes $'s\nrvi' |
    timeout 3s jupiter --debug "$ASM" 2> /dev/null |
    awk '/exit/ { exit }1' |
    sed 's/>>> x0/>>>\nx0/g' |
    grep -Po '{= \K-?\d+(?=})|\(\K0x[\da-f]+(?=\))' |
    tail -n +2 |
    xargs -n34 -d'\n' |
    tail -n +5 > "$RES2" &

jupiter --dump-code "$HEX" "$ASM"
{ echo 'ibase=16;obase=2'; cat "$HEX" | tr a-z A-Z | sed 's/0X//'; } |
    bc | awk '{ printf("%32s\n", $1); }' |
    tr ' ' '0' |
    tail +6 > "$INS"
rm "$HEX"
vvp ../mytest.vvp "+file=$INS" 2> /dev/null |
    sed 's/ \+/ /g; s/^ \| \(0x00000000 \)\?$//g' |
    tail +2 > "$RES1"
rm "$INS"
wait $(jobs -p)

set +e

EXIT_CODE=0
cmp "$RES1" "$RES2"
if [ $? -ne 0 ]; then
  echo 'Instructions:' > error.log
  cat "$ASM" >> error.log
  echo 'Expected:' >> error.log
  cat "$RES2" >> error.log
  echo 'Got:' >> error.log
  cat "$RES1" >> error.log
  EXIT_CODE=1
fi

rm "$ASM" "$RES1" "$RES2"
exit $EXIT_CODE
