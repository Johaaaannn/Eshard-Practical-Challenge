# Part 3 – Security Perspective (Simplified English)

## Context

You are asked to audit a Dockerized web service that has **no rate limiting** and **logs plaintext passwords** to disk.  
This means two big problems:
1. Attackers can try unlimited passwords (brute-force).  
2. Sensitive passwords are stored in logs, which is a huge security risk.

---

## 1. What I would check

### a) Logs and data storage
- Where are passwords written? (local file, Docker volume, or external storage?)
- Who can read these log files?
- Are logs copied or backed up elsewhere?

### b) Authentication process
- Are passwords transmitted with **HTTPS** or plain **HTTP**?
- Are passwords **hashed** before being stored in the database?
- Is any part of the code printing sensitive data to console or log?

### c) Web access & brute-force protection
- How many login attempts can a user make?
- Are there protections like **CAPTCHA** or IP blocking?
- Are failed login attempts monitored or alerted?

### d) Docker environment
- Does the container run as **root** or a restricted user?
- Are the logs stored in a shared volume accessible by other containers?
- Is the filesystem **read-only** for better protection?

---

## 2. How I would fix it

### a) Stop logging passwords
- Change the code to **never log passwords**. Only log usernames or IP addresses.
- Secure existing logs:
  ```bash
  chmod 600 /var/log/app.log
  ```
- Delete old log files that contain passwords.

### b) Add rate limiting
Limit the number of login attempts per user or IP to stop brute-force attacks.  
Example (in Nginx):
```nginx
limit_req_zone $binary_remote_addr zone=login:10m rate=10r/m;

location /login {
    limit_req zone=login burst=5;
}
```
→ This blocks a user if they send too many login requests per minute.

### c) Secure communications
- Use **HTTPS** instead of HTTP.  
- Never send passwords in plain text.  
- If possible, use **OAuth** or **token-based authentication** instead of passwords.

### d) Improve Docker security
- Run as a **non-root** user.  
- Set the filesystem to **read-only**.  
- Drop unnecessary privileges:
  ```yaml
  cap_drop:
    - ALL
  security_opt:
    - no-new-privileges:true
  ```

### e) Log management
- Rotate logs (using `logrotate`) to prevent large files.  
- Store logs only for a limited time (e.g. 7–14 days).  
- Restrict who can read or access logs.

---

## 3. Questions I would ask

1. Are these real user accounts or only test data?  
2. How many login attempts should be allowed before blocking?  
3. Do we need to keep logs for compliance or audit reasons?  
4. Who has access to the logs?  
5. Should we notify users if their passwords were exposed in logs?  
6. Are other services (like monitoring or reverse proxy) also storing these logs?

---

## Summary

| Problem | Fix |
|----------|------|
| Passwords stored in logs | Stop logging them and delete old files |
| No login protection | Add rate limiting or lockout after too many tries |
| Weak Docker setup | Run without root, read-only filesystem, drop privileges |
| Sensitive logs | Restrict access and apply log rotation |

---

**In short:**  
- **Check:** logs, authentication, network access, Docker permissions.  
- **Fix:** stop plaintext logs, add rate limiting, secure communications, tighten Docker security.  
- **Ask:** about business needs, compliance, and who can access sensitive data.

---

**Author:** Johann Laporal  
(Part of the eShard Technical Assessment – October 2025)
