RANCID Scripts for VyOS/Vyatta
======

VyOS (Vyatta) scripts for Rancid.  Forked from 
https://github.com/damianfantini/rancid and 
https://github.com/natecarlson/vyatta-rancid

vrancid appears to be very similar to some other scripts that are floating around the web.

Includes:

* vlogin - basic login script, confirmed to work with VyOS
* vrancid - the Rancid wrapper to actually grab the configs

To integrate into your RANCID install:

* Copy vlogin and vrancid to your 'bin' directory
* Modify 'rancid.types.conf', and add vrancid.. IE:

```
vyos;script;vrancid
```
* Add a new device to your 'router.db', with the vendor of 'vyos'
* Use it  :)

Todo

* Add more commands