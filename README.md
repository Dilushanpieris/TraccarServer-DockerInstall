# TraccarServer-DockerInstall Guide

Offical Method to Install Traccar Server on Ubuntu-Linux Server . Supports Push Notifications And SSL Web Interface. 
<hr>

## Step 01 - Prepare Linux Environment
>[!TIP]
> Fully Install Ubuntu Linux on VPS. And Make Sure Its Ubuntu 24.04 LTS/Non LTS Do Not Use Deprecated Editions.You Need Root Access for Perform Install Correctly. Use **sudo -s** To Gain Root Access.

### Run These Commands To Update Packages
```
sudo apt-get update 
sudo apt-get upgrade
sudo apt-get install cron
sudo apt-get install -y socat
sudo apt install netcat-openbsd


```

### Time/Geo Zone Configuration. 

```
sudo dpkg-reconfigure tzdata
```

### Firewall Configuratations.
>[!IMPORTANT]
>Firewall In Ubuntu Usually Have 2 Layers That Provided by VPS Panel And OS Level. Some Providers Only Provide Panel Level Firewall Only. Make Sure to Configure Panel Level Firewall Ports Before Continuting. Providers Like Linode/Zomro/OVH/Contaboo Have Open Firewall. So No Configurations Needed.But Risky. Make Sure to Configure Correctly.

**Check If The Ports You Need Are Open Properly**
>[!TIP]
>This Command Will Open port 80 for 60 secs And you Can Test The Firewall With Given Online Tester By Pinging into Port. 

```
sudo timeout 60s socat -v TCP-LISTEN:80,reuseaddr,fork -
```

[PortChecker.io- Check Open Ports](https://portchecker.co/)


**Open Firewall Ports-Iptables (For Oracle Cloud)**
>[!CAUTION]
>Only Make Changes To OS Level Firewall If Ports Are Not Opened. And Test Fails. 

*Check For Ip-Table Rules*
```
sudo iptables -L INPUT -n --line-numbers
```

*find if The Rules Are missing and Add New Rules With Your Positions to avoid Reject Rules. In This Case I Used Position 4*
```
sudo iptables -I INPUT 4 -m state --state NEW -p tcp --dport 8082 -j ACCEPT  # Panel Port 
sudo iptables -I INPUT 4 -m state --state NEW -p tcp --dport 5001 -j ACCEPT  # GPS Test Port 
sudo iptables -I INPUT 4 -m state --state NEW -p tcp --dport 5013 -j ACCEPT  # GPS Ingress Port-TCP
sudo iptables -I INPUT 4 -m state --state NEW -p udp --dport 8013 -j ACCEPT  # GPS Ingress Port-UDP
sudo iptables -I INPUT 4 -m state --state NEW -p tcp --dport 443 -j ACCEPT   # HTTPS Port
sudo iptables -I INPUT 4 -m state --state NEW -p tcp --dport 8080 -j ACCEPT  # Backup Port
sudo iptables -I INPUT 4 -m state --state NEW -p tcp --dport 80 -j ACCEPT    # SSH Port Usually Open
sudo netfilter-persistent save
sudo iptables -L INPUT -n --line-numbers
```

>[!TIP]
>Now Open Port for 60s and Test Again With Port Checker.Port 8013 Can Be Different According To your GPS Protocol. I Will Show How you Can Identify the Protocal And Port In Next Step And You Have To Add That Port Insted of 8013 here. if the VPS Has OS Based FW Layer.

### Point IP For Domain Using DNS (Free Domains Are Avalible)
>[!WARNING]
>pointing to Domain Doesnot Give You SSL/ SSL Certification Is Optional. But You Can Have Panel URL As You Point To DNS.

[DuckDNS](https://www.duckdns.org/) <br>
[DynuDNS](https://www.dynu.com/en-US) <br>
[FreeDNS](https://freedns.afraid.org/)



## Step 02 - Find Your GPS Protocol And Port. 

>[!IMPORTANT]
>To Find Tracker Protocol We Use Netcat to Listn to The Test Port. Before Anything Make Sure To Configure Your GPS To Talk to Server ip And The Port of 5001 As The Test Port. XXX.XXX.XXX.XXX:5001 Common GPS Modules Use SMS To Setup GPS IP Address. GPS Must Have Valid Data Connection and SIM.

**Run This Commnd To Sniff Port 5001**

```
sudo nc -l 5001 | hexdump -C
```
>[!TIP]
>Now Look For Right Most ASCII Output To Find out What Is Your Tracker Protocol is. You may See Dataset of Your Tracker Sending to your Server Via Port 5001.

**Here Are The Most Common Tracker Hex**

| Signature (ASCII) | HEX Header     | Common Brand / Name     | Correct Traccar Port |
|-------------------|----------------|-------------------------|----------------------|
| imei:             | 69 6d 65 69 3a | Coban / GPS103          | 5001                 |
| *HQ               | 2a 48 51       | Sinotrack / H02 / HQ    | 5013                 |
| 78 78             | 78 78          | Concox / GT06 / JimiIoT | 5023                 |
| (                 | 28             | TK103 / Kingneed        | 5002                 |
| $$                | 24 24          | Meiligao                | 5009                 |
| #                 | 23             | Queclink                | 5004                 |
| [                 | 5b             | Watch / Kids Trackers   | 5093                 |

**Now You Know The Port And Now You Can Open That Port on Firewall**

**Also Here Is The Universal Traccar List To Find out What Port and Protocol Your Tracker Supports** <br>
[Traccar Supported Devices And Ports](https://www.traccar.org/devices/)


## Step 03 - Install Docker Environment

>[!TIP]
>Docker Install Is Required Because it Can Use Resources Very optimized With A Swap Area For Low Ram Instances. 

```
bash <(curl -sSL https://raw.githubusercontent.com/Dilushanpieris/TraccarServer-DockerInstall/refs/heads/main/dockerinstall.sh)
```

## Step 04 - Acquire Your API Key From Traccar.

>[!TIP]
>You Need To Have Push Notification API Key To Communicate With Android Traccar Application Push Notifications. Acquire Your API Key by Making Account At [Traccar.org](https://www.traccar.org/my-account/) And Note Down APi Key. **API Key Have 64 Charachters** Looks Like..

```
MnpuZWZ4bjZHRlpDTQeyJkYXRhIjo1MTA2N30uN3BPMTlkbWF2Y1kwam8wc0s1V1V5M2pwa3lz         # Sample API Key FYI
```

## Step 05 - Install Traccar Using The Script

>[!IMPORTANT]
>To Run Below Install Command. You May Have API Key , Traccar Panel Port And The Correct Tracker Port For Your GPS. 

**To Install Traccar Run**

```
bash <(curl -sSL https://raw.githubusercontent.com/Dilushanpieris/TraccarServer-DockerInstall/refs/heads/main/traccar-install.sh)
```


## Step 06 Create SSL Certs For Web Panel (HTTPS)

>[!TIP]
>For Traccar SSL Is Optional to Ensure Complience. For GPS Only Use IP Address and For Traccar Application Use. Http/ Https  absed on Your Preference.

**To Install Nginx Proxy Manager**

```

```

>[!IMPORTANT]
>You Will Wnd up With Local IP Address That Looks Mostly Like 172.17.0.1 At The Script End Use It As Forward Destination on Proxy manager. 

### Setup Procedure For NGinix Proxy.
Go to Domain That Printed on your Script.

Hosts > Proxy Hosts > Add Proxy Host 
Add your Domain Name As The Domain Name 
scheme : http
Forward Hostname: use Hostname Printed At The End Of Script (Usually 172.17.0.1)
Forward Port: Your Traccar Port (Default use 8082)
Block Common Exploits: On.
Websockets Support: On (Crucial for live tracking).

Finally Generate SSL Certs With SSL Tab. (Create New Certificate)


## Step 07 Uninstall Traccar From VPS.
>[!TIP]
>Before Uninstall Traccar Make Sure To Remove Your GPS From The Panel And Then Procced With Following Command. 

```
bash <(curl -sSL https://raw.githubusercontent.com/Dilushanpieris/TraccarServer-DockerInstall/refs/heads/main/traccar-uninstall.sh)

```