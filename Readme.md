# Speedlight BMv2 #

This repository contains a BMv2 adaptation of the Speedlight P4 dataplane, originally implemented for the Barefoot Tofino. 

### Contents ###

- `p4src/` -- The P4 source code of Speedlight.
  - `includes/p4/` -- P4 includes that are shared amongst all variants.
  - `primitives/` -- Stateful primitives for Speedlight.
- `snapshot_init/` -- Snapshot initiation program.
- `third_party/` -- bmv2 and p4v-bm submodules.

### Naming Conventions ###

For file names:
- `*_W` -- Contains code for handling wrapping of the snapshot ID back to zero.
- `*_C` -- Contains code for capturing channel state, not just local processing unit state.

For function names:
- `t*` -- match table
- `a*` -- action definition
- `r*` -- stateful register operation
- `i` or `e` as a second letter indicates ingress or egress.  None indicates it is used for both.
For example, `tiCheckRollover` is a table used during ingress, `reUpdateSnapshotId` is a stateful operation used during egress, and `aCheckSnapshotCase` is an action used in both directions.

### Compiling the dataplane ###

This release has been tested on Ubuntu 16.04 LTS, but should work on Ubuntu 14.04+.
p4 simluator has a large memory requirement. We used it in 32gb RAM.
The following instructions assume 3 windows: (1) switch behavioral model, (2) notification listener, and (3) snapshot initiation script.

1. Setup.
	```
	# Installs all prerequisites and compiles the Speedlight dataplane, including:
	# https://github.com/p4lang/behavioral-model/commit/66cefc5e901eafcebb0e1a8f681a05795463215a
	# https://github.com/p4lang/p4c-bm/commit/d75624e18f4ae79e9e5cb478c33d221711f76574
	# Also sets up the virtual network interfaces for BMv2
	./setup.sh
	```

2. Compile and run the Speedlight dataplane.
	```
	# <VARIANT>            {Pkt, Pkt_W, Pkt_WC}
	# <NUM_PORTS>          Number of ports in the switch.
	# <MAX_SNAPSHOT_ID>    Highest valid snapshot ID. Without wraparound (*_W),
	#                      behavior above this value is undefined. With wraparound,
	#                      this number determines the maximum number of outstanding
	#                      snapshots.
	./start_switch.sh <VARIANT> <NUM_PORTS> <MAX_SNAPSHOT_ID>
	# Leave this window open
	```

3. In a new window, install the match-action rules and start listening for notifications.
	```
	# <VARIANT>            {Pkt, Pkt_W, Pkt_WC}. Must match parameter given to
	#                      start_switch.sh.
	./start_listening.sh <VARIANT>
	# Leave this window open.  Notifications will output here.
	```

4. In a third window, initiate a snapshot.
	```
	# <HH>                 Hour of snapshot according to the Unix date command
	# <MM>                 Minute of snapshot according to the Unix date command
	# <NUM_PORTS>          Number of ports in the switch. Must match parameter given
	#                      to start_switch.sh.
	# This will initiate a single snapshot with ID = 1 in a parallel fashion.
	# Port responsibilities are spread across available cores to increase the 
	# speed at which we can issue a sequence of snapshot initiations.
	# Example: ./start_snapshot 17 09 10
	# This will take snapshot for 10 ports at time 5:09 pm.
	./start_snapshot.sh <HH> <MM> <NUM_PORTS>

	# You can also access the original, more flexible snapshot initiation 
	# that is compiled to the following program.  This one is required for
	# subsequent snapshots, etc.
	out/startsnap
	```

### Troubleshooting ###

1. If the start_listening.sh output includes the following:
```
Invalid table operation (DUPLICATE_ENTRY)
```
Please make sure to restart the switch between invocations of start_listening.sh

2. If start_listening.sh prints nonsensical values, ensure that the VARIANT parameters of start_switch.sh and start_listening.sh match.

3. If the start_switch.sh crashes with:
```
lt-simple_switch: ../../include/bm/bm_sim/stateful.h:111: bm::Register& bm::RegisterArray::operator[](size_t): Assertion `idx < size()' failed.
```
Ensure that you are running start_snapshot.sh with NUM_PORTS <= start_switch.sh's NUM_PORTS


### Limitations ###

Note that this BMv2 version can only handle a small number of snapshot packets at a time---the behavioral model simply can't keep up with the pace of packets.  At higher port counts, particularly with channel state notifications, initiation and notification drops occur.  Our Tofino version does not have this limitation.
