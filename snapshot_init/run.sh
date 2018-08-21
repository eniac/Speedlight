#! /bin/bash

set -e

if [ $# -lt 3 ]; then
	echo "Usage: ./run.sh HH MM numports"
	exit 1
fi

g++ -std=c++11 startsnap.cpp -o startsnap


CORES=$((`nproc` - 1))
STEP=$(($3/$CORES))

NUM_HIGH=$(($3 - ($STEP * $CORES)))
NUM_LOW=$(($CORES - $NUM_HIGH))

PORT=1
for (( i=0; i < $NUM_HIGH; i++))
do
        sudo ./startsnap $1 $2 $PORT $(($PORT + $STEP + 1)) &
        PORT=$(($PORT + $STEP + 1))
done
for (( i=0; i < $NUM_LOW; i++))
do
        sudo ./startsnap $1 $2 $PORT $(($PORT + $STEP)) &
        PORT=$(($PORT + $STEP))
done

wait
