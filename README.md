# eShard – Practical Challenge (Secure Docker Web Service)

## 🧩 Overview
This project simulates a **minimal secure web service** deployment using Docker and Nginx.  
It includes container hardening, basic monitoring, and a deliberate vulnerability for demonstration.

---

## ⚙️ Setup

### Requirements
- Docker Desktop with WSL2 backend  
- Ubuntu WSL2 environment  
- Cron service enabled

### Installation
```bash
git clone https://github.com/Johaaaannn/Eshard-Practical-Challenge
cd eshard-practical-challenge
docker compose up -d
```

Access the service at:
- **http://localhost:8080/** → default Nginx page  
- **http://localhost:8080/status** → exposed Nginx stub_status  
- **http://localhost:8080/admin/** → intentionally exposed directory

---

## 🧱 Security Controls Implemented

| Area | Description |
|------|--------------|
| **Least privilege** | Container runs as non-root user (`101:101`) |
| **Read-only filesystem** | Root FS mounted read-only to prevent tampering |
| **Tmpfs mounts** | `/run`, `/var/run/nginx`, `/var/cache/nginx` use `tmpfs` with restricted ownership |
| **Capability dropping** | `cap_drop: ALL` removes all Linux capabilities |
| **No privilege escalation** | `security_opt: no-new-privileges:true` |
| **Persistent logs** | Logs stored on external volume (`./logs`) with limited permissions |
| **Network filtering** | (Simulated) firewall rules allowing only ports 22 and 8080, DNS allowed, all else blocked |

---

## 🔐 Simulated Firewall Rules (documented – not applied in WSL)

If running on a full Linux host:
```bash
iptables -P INPUT DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A DOCKER-USER -p udp --dport 53 -j ACCEPT
iptables -A DOCKER-USER -j DROP
```

On WSL, this layer is **simulated/documented**.

---

## 📊 Monitoring

A cron job checks memory usage every 5 minutes:
```bash
*/5 * * * * root /usr/local/bin/check_mem.sh
```

Logs are written to `/var/log/websvc/mem_alert.log`.  
Example:
```
2025-10-06T16:23:25+02:00 OK: Memory usage 10% < 70%
```

If usage exceeds 70%, an alert is appended:
```
2025-10-06T16:45:12+02:00 ALERT: Memory usage 82% >= 70%
```

---

## ⚠️ Simulated Vulnerability

1. **Exposed Admin Directory**
   - `/admin/` allows directory listing and contains a world-readable `secrets.txt` file (`chmod 777`).
2. **Exposed Status Page**
   - `/status` exposes live Nginx metrics without authentication.

### ✅ Fix Recommendation
```nginx
location /status {
  stub_status;
  allow 127.0.0.1;
  deny all;
}

location /admin/ {
  autoindex off;
  return 403;
}
```
And restrict file permissions:
```bash
chmod 640 admin/secrets.txt
```

---

## 🧾 How to Run Tests

```bash
# Start environment
docker compose up -d

# Verify service availability
curl -I http://localhost:8080/
curl    http://localhost:8080/status
curl -I http://localhost:8080/admin/

# Run manual monitoring check
sudo /usr/local/bin/check_mem.sh
sudo tail -n 10 /var/log/websvc/mem_alert.log
```

---

## 🧰 Tech Stack
- **Base image**: `nginx:1.27-alpine`
- **Container runtime**: Docker Compose v2
- **OS**: Ubuntu 24.04 LTS (WSL2)
- **Monitoring**: Cron + shell script
- **Security baseline**: no-new-privileges, capability dropping, read-only FS, tmpfs isolation

---

## 👤 Author
**Johann Laporal**  
IT Systems & Network Apprentice  
(Challenge performed on WSL – Ubuntu 24.04 LTS, Docker Desktop 28.4)
