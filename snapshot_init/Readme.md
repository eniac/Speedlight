### PTP Synchronized Snapshot Initiation ###

1. Ensure that ptp is install and running with hardware timestamping.  PTP can be installed from either packages or source (http://linuxptp.sourceforge.net/).

2. Start the switch agent per the instructions in `../switches_snapshot`

3. Execute `./run.sh HH MM numports` to initiate **one** snapshot through the **bf_pci0** at time **HH:MM** across ports **1** to **numports**.  Each of these options, plus **interval time** is configurable by running startsnap directly.
