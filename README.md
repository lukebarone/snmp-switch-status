# SNMP Switch Status

This project runs on Bash (with colours) to show you, via SNMP, what plugs are
connected on your switch, along with whether they are running at gigabit
speeds or lower.

## Switch Setup

Your switches must support SNMP v3 (untested with earlier non-encrypted
versions). Instructions are going to vary from manufacturer to manufacturer,
as well as from model to model.

With **Cisco SG300** switches with the Web Interface available:

1. Create a default Engine ID (SNMP -> Engine ID -> Use Default)
2. Create a default Group with SNMPv3 Security Model, and Privacy Views for **DefaultSuper**
3. Create your user, part of the group you created above, with the **SHA** Authentication Method, and **DES** Privacy Method. You'll need you **Authentication Password** and your **Privacy Password** for the configuration.
4. Enable SNMP (Security -> TCP/UDP Services -> Check **SNMP Service**)

With **HPE 1950** Series switches with the Web Interface available:

1. Enable SNMP v3 (Network -> SNMP). Click on Versions, and ensure v3 is chosen.
2. Create a default Group with **AuthPriv** Security Level, and **ViewDefault** for the three views.
3. Create your user, part of the group you created above, the **AuthPriv** security level, with **SHA** Authentication Mode, and **AES128** for Privacy Mode. You'll need you **Authentication Key** and your **Privacy Key** for the configuration.

With the **HPE 1820** Series switches with the Web Interface available:

1. Enable SNMP v3 (Device -> SNMP). Choose SNMP -> Enable, and v3. Hit Apply.
2. Create a default Group with **AuthPriv** Security Level, and **ViewDefault** for the three views.
3. Create your user, part of the group you created above, the **AuthPriv** security level, with **SHA** Authentication Mode, and **AES128** for Privacy Mode. You'll need you **Authentication Password** and your **Privacy Password** for the configuration.

### Testing SNMP

Download a tool to walk through the SNMP OIDs, such as [SNMP Tester by Paessler](https://www.paessler.com/tools/snmptester).

- Device IP/Port: The IP Address of your device you're testing, and likely port 161 for the default
- SNMP Version: **SNMP v3**
- SNMP User: The user you created above
- Authentication: SHA (if you're following above)
- Password: The **Authentication Password/key** for your user
- Encryption: AES (or DES)
- v3 Encryption Key: **Privacy Password/key** for your user's password
- Walk: `1.3.6.1.2.1.2.2.1.5`
- Click **Start**. You should see a successful connection, and the interface IDs loading.

## Creating your initial configuration file

There are two files of note: `switches.conf` for each individual switch, and `.env` for your private information (usually your username, password and encryption key). See the example files for an example (**WARNING** - Comments are not supported yet). These files should be in the same folder as the script.

### .env

USERNAME="UsernameGoesHere"
AUTH_PASS="Authentication Password or Key"
ENC_KEY="Privacy Password or Key"

### switches.conf

Each entry is one line, with options separated by whitespace:

    IPA.dd.re.ss    AuthMethod  PrivMethod  LowID   HighID  Name

For example, if you have an HPE switch (first line) and a Cisco Switch (second line) on your network, it may look like this:

```nolang
10.1.2.3  SHA AES 1   52  Switch23
10.1.4.5  SHA DES 49  76  Switch45
```