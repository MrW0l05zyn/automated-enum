# Automated Enum

Herramienta de enumeración automatizada.

## Uso

```bash
automatedEnum.sh -t <TARGET> [-m <MODE>] [-s <SERVICE>]
```

## Ejemplos de utilización

```bash
./automatedEnum.sh -t X.X.X.X
./automatedEnum.sh -t X.X.X.X -s HTTP
./automatedEnum.sh -t X.X.X.X -m full
./automatedEnum.sh -t X.X.X.X -m vuln -s SMB
```

## Argumentos

```
-t <TARGET>     Target/Host IP address
-m <MODE>       Mode: basic|vuln|full (default: basic)
-s <SERVICE>    Service name: FTP|HTTP|HTTPS|RDP|REDIS|SMB|SMTP|SNMP|SSH
-h              Shows instructions on how to use the tool
```

## Instalación

```bash
cd /opt
git clone https://github.com/MrW0l05zyn/automated-enum.git
sudo ln -s $(pwd)/automated-enum/automatedEnum.sh /usr/local/bin/
```

### Dependencias

+ [dirsearch](https://github.com/maurosoria/dirsearch)
+ [nmap](https://nmap.org/)
+ [seclists](https://github.com/danielmiessler/SecLists)
+ [smbclient](https://www.samba.org/)
+ [smbmap](https://github.com/ShawnDEvans/smbmap)
+ [smtp-user-enum](http://pentestmonkey.net/tools/user-enumeration/smtp-user-enum)
+ [snmp-check](http://www.nothink.org/codes/snmpcheck/index.php)
+ [whatweb](https://morningstarsecurity.com/research/whatweb)

### Instalación de dependencias

```bash
sudo apt update
sudo apt install dirsearch nmap seclists smbclient smbmap smtp-user-enum snmp-check whatweb
```