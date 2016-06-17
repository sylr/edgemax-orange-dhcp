# THIS IS A WORK IN PROGRESS

# About

An example of configuration for your Edgemax PoE router and the French ISP Orange.

  - IPv4 with DHCP
  - IPv6 with DHCP-PD and Router Advertisement
  - TV (VoD, Canal+ & Bein should work)

**IF YOU ARE LIKE JON SNOW AND YOU KNOW NOTHING, STOP HERE AND DON'T TRY IT YOURSELF!**

![you know nothing](http://i0.kym-cdn.com/photos/images/original/000/527/985/04f.gif)

# Disclaimer

**THIS CONFIGURATION IS WORKING FOR ME BUT I DON'T GUARANTEE THAT IT WILL WORK FOR YOU**

**I RECOMMEND THAT YOU HAVE ACCESS TO THE CONSOLE PORT OF YOUR ROUTER IF THINGS GO WRONG**

**IF ANY DAMAGE HAPPENS TO YOUR HARDWARE I CAN'T BE HELD RESPONSIBLE FOR IT**

**ALSO THE FIREWALL RULES MIGHT NOT SUIT YOUR NEEDS AND CAN POSSIBLY HAVE SOME HOLES SO IF SOMEONE ACCESS YOUR NETWORK I CAN'T BE HELD RESPONSIBLE**

# Tanks & Credits

 - Guys from the lafibre.info board and especially those of the "[Remplacer sa Livebox par un routeur Ubiquiti Edgemax](https://lafibre.info/remplacer-livebox/en-cours-remplacer-sa-livebox-par-un-routeur-ubiquiti-edgemax)" thread
 - [Zoc](https://lafibre.info/profile/zoc/) for the patched dhclient3 and dibbler-client

# Topology

- **Port 1 (eth0):** lan (Netgear Switch)
- **Port 2 (eth1):** up link orange (ONT)
- **Port 3 (eth2):** Livebox TV
- **Port 4 (eth3):** down link to dmz
- **Port 5 (eth4):** WIFI App
- **Switch 0 (switch0):** eth3 eth4

# Firewall Zones

- **lan**: eth0 (10.10.40.0/24) switch0.198 (10.10.198.0/24)
- **wan**: eth1 eth1.832
- **wan-tv**: br0 eth1.838 eth1.840 eth1.841 eth2
- **wifi-guest**: switch0.199 10.10.199.0/24
- **dmz**: eth3
- **local**

# Install

### Backup your current configuration

You can do that in web GUI. **Don't go further without a complete backup of your current configurations.**

### Download archive

```shell
sudo -i
apt-get install wget patch
wget https://github.com/sylr/edgemax-orange-dhcp/archive/master.tar.gz
tar xzvf master.tar.gz
cd edgemax-orange-dhcp-master
```

### Extract new binaries

```shell
cp /sbin/dhclient3 /sbin/dhclient3-original
cd files && tar xvzf dhclient3.tgz && cd -
cp files/dhclient3 /sbin/

dpkg -i files/dibbler-client_1.0.1-1~bpo80+1_mips.deb
```

### Apply patches

```shell
cp files/rfc3442-classless-routes /etc/dhcp3/dhclient-exit-hooks.d/
patch -p0 < files/vyatta-dhcp-option-90.patch
```

### Edit configuration files

```bash
./fti-hex-generator.sh a5rt89g
```

- Replace all occurences of **XXXXXXXXXXXXXX** in **config-dhcp.boot** with correct configurations.
- Make sure to edit the **system** scope correctly otherwise you could loose access to your router.

- Replace **MA:CD:EL:AL:IV:EB:OX** with your Livebox Mac address in **config-dhcp.boot**.
- Replace **MA:CD:EL:AL:IV:EB:OX:TV** with your Livebox TV Mac address (leave the "1:" in front of your mac address) in **config-dhcp.boot**.
- Replace **00:00:00:00:00:00:ST:RI:NG:HE:XA:DE:VO:TR:EI:DE:NT:IF:IA:NT:0F:TI** with the string generated with ```./fti-hex-generator.sh <your fti/ login>``` in **config-dhcp.boot** & **files/dibbler-client.conf**.
- Adjust the **INT_SUFFIX** variable in **files/dibbler-radvd.sh**.

### Copy configuration files

```shell
cp /config/config.boot /config/config.boot-$(date +%Y%m%d)
cp config-dhcp.boot /config/config.boot
cp files/dibbler-client.conf /etc/dibbler/client.conf
cp files/dibbler-radvd.sh /etc/dibbler/radvd.sh
```

### Reboot

... debug.
