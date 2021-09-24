# Automated Enum

Herramienta de enumeración automatizada.

## Uso

```bash
automatedEnum.sh -t <TARGET> [-m <MODE>] [-s <SERVICE>]
```

## Ejemplos de utilización

```bash
./automatedEnum.sh -t 10.0.0.1
./automatedEnum.sh -t 10.0.0.1 -m full
./automatedEnum.sh -t 10.0.0.1 -s HTTP
```

## Argumentos

```
-t <TARGET>     Target/Host IP address
-m <MODE>       Mode: basic|full (default: basic)
-s <SERVICE>    Service name: HTTP|HTTPS|SMB|SMTP|SNMP|SSH
-h              Shows instructions on how to use the tool
```

## Instalación

```bash
git clone https://github.com/MrW0l05zyn/automated-enum.git
cd automated-enum && chmod +x automatedEnum.sh
```

### Dependencias

+ dirsearch
+ nmap
+ seclists
+ smbclient
+ smbmap
+ smtp-user-enum

### Instalación de dependencias

```bash
sudo apt update
sudo apt install dirsearch nmap seclists smbclient smbmap smtp-user-enum
```