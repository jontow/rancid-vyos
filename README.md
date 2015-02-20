RANCID Scripts for VyOS/Vyatta
======

VyOS (Vyatta) scripts for Rancid.  Forked from
https://github.com/damianfantini/rancid and
https://github.com/natecarlson/vyatta-rancid

Includes:

* vlogin - basic login script, confirmed to work with VyOS
* vyos.pm - the Rancid wrapper module to actually grab the configs
* rancid.types.conf - additional device type configuration

To integrate into your RANCID install:

* Copy vlogin to your 'bin' directory
* Copy vyos.pm to your PERL5LIB rancid directory
* Append rancid.types.conf to your existing rancid.types.conf file (or create it if it doesn't exist)
* Add a new device to your 'router.db', with the vendor of 'vyos'
* Use it  :)

Todo

* Add more commands