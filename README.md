RANCID Scripts for VyOS/Vyatta
======

VyOS (Vyatta) scripts for Rancid.  Forked from
https://github.com/damianfantini/rancid and
https://github.com/natecarlson/vyatta-rancid

Includes:

* vlogin - basic login script, confirmed to work with VyOS
* vyos.pm - the Rancid wrapper module to actually grab the configs

To integrate into your RANCID install:

* Copy vlogin to your 'bin' directory
* Copy vyos.pm to your PERL rancid directory
* Add the following to 'rancid.types.conf':
```
vyos;script;rancid -t vyos
vyos;login;vlogin
vyos;module;vyos
vyos;inloop;vyos::inloop
vyos;command;vyos::ShowHardware;show hardware cpu
vyos;command;vyos::ShowHardware;show hardware dmi
vyos;command;vyos::ShowHardware;show hardware pci
vyos;command;vyos::ShowHardware;show hardware scsi
vyos;command;vyos::ShowHardware;show hardware usb
vyos;command;vyos::ShowVersion;show system routing-daemons
vyos;command;vyos::ShowVersion;show system image
vyos;command;vyos::ShowVersion;show version all
vyos;command;vyos::ShowConfiguration;show configuration
vyos;command;vyos::ShowConfiguration;show configuration commands
```
* Add a new device to your 'router.db', with the vendor of 'vyos'
* Use it  :)

Todo

* Add more commands