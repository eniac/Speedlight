#! /bin/bash

set -e

if [ $# -lt 3 ]; then
	echo "Usage: ./start_snapshot.sh HH MM numports"
	exit 1
fi
# $3 = 4
CORES=$((`nproc` - 1))
STEP=$(($3/$CORES))

NUM_HIGH=$(($3 - ($STEP * $CORES)))
NUM_LOW=$(($CORES - $NUM_HIGH))

PORT=1
for (( i=0; i < $NUM_HIGH; i++)) 
do
		echo "high starting $PORT, ending inclusive: $(($PORT + $STEP))"
        sudo out/startsnap -d veth1 $1 $2 $PORT $(($PORT + $STEP + 1)) &
        PORT=$(($PORT + $STEP + 1))
done
if [ "$STEP" != 0 ]; then
	for (( i=0; i < $NUM_LOW; i++))
	do
			echo "starting: $PORT, ending inclusive: $(($PORT + $STEP - 1))" 
	        sudo out/startsnap -d veth1 $1 $2 $PORT $(($PORT + $STEP)) &
	        PORT=$(($PORT + $STEP))
	done
fi


wait
