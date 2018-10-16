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
	# <VARIANT>={Pkt, Pkt_W, Pkt_WC}
	./start_switch.sh <VARIANT> <NUM_PORTS> <MAX_SNAPSHOT_ID>
	# Leave this window open
	```

3. In a new window, install the match-action rules.
	```
	./install_rules.sh
	```

4. In a third window, initiate a snapshot.
	```
	# This will initiate a single snapshot with ID = 1 in a parallel fashion.
	# Port responsibilities are spread across available cores to increase the 
	# speed at which we can issue a sequence of snapshot initiations.
	./start_snapshot.sh <HH> <MM> <NUM_PORTS>

	# You can also access the original, more flexible snapshot initiation 
	# that is compiled to:
	out/startsnap
	```

### Notes ###

The snapshot initiation assumes EDT.  Please change snapshot_init/startsnap.cpp line 275.
