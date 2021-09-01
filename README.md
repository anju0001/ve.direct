# ve.direct
Victron ve.direct emulator for Linux

This repo contains a simple BASH script to emulate a Victron BlueSolar 75/15 MPPT charger.
These solar chargers send a text data frame every second with certain values like solar voltage and others.

For development of a display to show me these values, I needed an emulator because my solar controller was mounted in a shed.
So this script was born :) 
You can modify the parameters sent to fit your controller (maybe change the PID then as well).
Only a few commandline tools like shuf and stty are needed.

The script also calculates the checksum for each frame.
Uses the serial interface as parameter, e.g.

  ./victron_emulator.sh /dev/ttyUSB1

If called without parameter for serial interface, it will output the data frame on screen.
Be aware, that the checksum value is not always a printable ASCII character and might be a terminal control character and mess up/freeze your terminal ;)

Use at your own risk, think about voltage levels (TTL, RS232, ...) if you intend to use this to connect the interface to any hardware device!

