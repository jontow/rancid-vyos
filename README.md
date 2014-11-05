RANCID Scripts for VyOS/Vyatta
======

Vyatta (VyOS) scripts for Rancid. Forked from https://github.com/damianfantini/rancid;
vrancid appears to be very similar to some other scripts that are floating around the web.

Includes:
* vlogin - basic login script, confirmed to work with VyOS
* vrancid - the Rancid wrapper to actually grab the configs

To integrate into your RANCID install:
* Copy vlogin and vrancid to your 'bin' directory
* Modify 'rancid-fe', and add vrancid to your vendor table.. IE:

```
%vendortable = (
<...>
    'vyos'              => 'vrancid',
);
```
* Add a new device to your 'router.db', with the vendor of 'vyos'
* Use it  :)

h5. Todo

* Add more commands (IE, 'show configuration commands' to make the config easy to restore, 'sh ver', etc)
