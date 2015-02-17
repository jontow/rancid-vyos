RANCID Scripts for VyOS/Vyatta
======

VyOS (Vyatta) scripts for Rancid.  Forked from
https://github.com/damianfantini/rancid and
https://github.com/natecarlson/vyatta-rancid; vrancid appears to be very
similar to some other scripts that are floating around the web.

Includes:

* vlogin - basic login script, confirmed to work with VyOS
* vyos.pm - the Rancid wrapper module to actually grab the configs
* vrancid - the Rancid wrapper to actually grab the configs (deprecated)

To integrate into your RANCID install:

* Copy vlogin and vrancid to your 'bin' directory
* Copy vyos.pm to your PERL rancid directory
* Add the following to 'rancid.types.conf':
```
vyos;script;rancid -t vyos
vyos;login;vlogin
vyos;module;vyos
vyos;inloop;vyos::inloop
vyos;command;vyos::ShowConfiguration;show hardware cpu
vyos;command;vyos::ShowConfiguration;show hardware dmi
vyos;command;vyos::ShowConfiguration;show hardware pci
vyos;command;vyos::ShowConfiguration;show hardware scsi
vyos;command;vyos::ShowConfiguration;show hardware usb
vyos;command;vyos::ShowConfiguration;show system routing-daemons
vyos;command;vyos::ShowVersion;show system image
vyos;command;vyos::ShowVersion;show version all
vyos;command;vyos::ShowConfiguration;show configuration
vyos;command;vyos::ShowConfiguration;show configuration commands
```
* Add a new device to your 'router.db', with the vendor of 'vyos'
* Use it  :)

Todo

* Add more commands