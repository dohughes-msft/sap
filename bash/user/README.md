# User creation for SAP systems
## Introduction
With the bash scripts in this folder you can automate the creation of users, groups and assignments for SAP systems. You can edit the scripts to adapt them to your own standards for GID and UID numbers.

| Script | Use |
| ----------- | ----------- |
| `mkgu_sap.sh` | Create users for SAP HANA or SAP application servers |
| `mkgu_ora.sh` | Create users for Oracle |
| `mkgu_db6.sh` | Create users for DB2 LUW |

## Calling syntax
~~~~
mkgu_sap.sh -s <SAPSID> -n <SYSNO>
mkgu_ora.sh -s <SAPSID> -n <SYSNO> [-o]
mkgu_db6.sh -s <SAPSID> -n <SYSNO>
~~~~

`<SAPSID>` is the SID of the SAP system. User names like `<sid>adm` are derived from this.

`<SYSNO>` is a 2-digit number that will be used to derive GIDs and UIDs. The system number of the primary application server (PAS) is a good choice for this. Make sure to use the same number for each server in the SAP system.

`[-o]` is used for Oracle systems only. Use this flag if you have Oracle 12 or Oracle 11 + ASM. Some extra users and groups will be created.

## Default numbering convention

| GID | Used for |
| ---- | ---- |
| 2000-2099 | Cross-system SAP groups like `sapsys`, `sapinst` |
| 2100-2199 | Cross-system Oracle groups like `dba` |
| 2200-2299 | Cross-system DB2 groups (currently there are none) |
| 2300-2399 | Cross-system MaxDB groups like `sdb` |
| 2400-2499 | Cross-system HANA groups (currently there are none) |
| 3000-3999 | System-specific groups (any database) |

| UID | Used for |
| ---- | ---- |
| 2000-2099 | Cross-system SAP users like `sapadm` |
| 2100-2199 | Cross-system Oracle users like `oracle` |
| 2200-2299 | Cross-system DB2 users like `sapsr3` |
| 2300-2399 | Cross-system MaxDB users like `sdb` |
| 2400-2499 | Cross-system HANA users (currently none) |
| 3000-3999 | System-specific users (any database) |

## Example - SAP application server or HANA server
~~~~
mkgu_sap.sh -s HN1 -n 05
~~~~

This will produce the output:

~~~~
INFO:    Start execution of mkgu_sap.sh -s HN1 -n 05
INFO:    Tue Feb 4 16:09:11 UTC 2020
INFO:    Group sapinst added with GID 2001.
INFO:    Group sapsys added with GID 2002.
INFO:    User sapadm added with UID 2001.
INFO:    User hn1adm added with UID 3051.
INFO:    Stop execution of mkgu_sap.sh -s HN1 -n 05 with return code 0 (success).
INFO:    Tue Feb 4 16:09:11 UTC 2020
~~~~

## Example - Oracle database server
~~~~
mkgu_ora.sh -s NO1 -n 10 -o
~~~~

This will produce the output:

~~~~
INFO:    Start execution of mkgu_ora.sh -s NO1 -n 10 -o
INFO:    Tue Feb 4 16:11:00 UTC 2020
INFO:    Group sapinst created with GID 2001.
INFO:    Group dba created with GID 2101.
INFO:    Group oper created with GID 2102.
INFO:    Group asmdba created with GID 2103.
INFO:    Group asmoper created with GID 2104.
INFO:    Group asmadmin created with GID 2105.
INFO:    Group oinstall created with GID 2106.
INFO:    User oracle created with UID 2101.
INFO:    User orano1 created with UID 3102.
WARNING: no1adm does not exist so was not added to the database groups. You can re-run this script after creating this user.
INFO:    Stop execution of mkgu_ora.sh -s NO1 -n 10 -o with return code 1 (warning).
INFO:    Tue Feb 4 16:11:00 UTC 2020
~~~~

Note the warning. This occurs because the `<sid>adm` user does not exist. This is normal for a distributed system. If you are planning to install a central system with database and application on the same host, then run the `mkgu_sap.sh` script first.