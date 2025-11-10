# Bash System Health Script

Automated **Linux system health monitoring** using Bash — complete with a color-coded dashboard, log rotation, network monitoring, and optional email alerts.  

This project is great for **Help Desk**, **Network Engineering**, and **SysAdmin** students who want hands-on automation experience.

---

## Example Output

> <img width="657" height="448" alt="image" src="https://github.com/user-attachments/assets/232f3c76-7e0a-44fb-8abf-3165ebc6f09a" />


---

## Features

✅ **Dashboard-style display** with color-coded metrics  
✅ **CPU, Memory, Disk, Uptime, and Network usage**  
✅ **Automatic log rotation** (keeps 7 days of logs)  
✅ **Threshold-based alerts**  
✅ **Optional email notifications**  
✅ **Lightweight** — runs on any Linux distro  

---

## Requirements

- Linux 
- Bash shell 
- `mailutils` (if using email alerts)
- Basic permissions to write to `/var/log`

Install mailutils if you want alerts:
```bash
sudo apt install mailutils -y
