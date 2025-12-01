# DevOps CI/CD Pipeline - PetClinic Deployment with Nagios Monitoring

## Architecture Diagram

![CI/CD Pipeline Architecture](diagram.png)

---

## Project Overview

This project implements a complete **CI/CD pipeline** that automatically builds, deploys, and monitors the **Spring PetClinic** application.

| Tool | Purpose | Port |
|------|---------|------|
| **Jenkins** | CI/CD automation | 8080 |
| **Ansible** | Configuration management | - |
| **Tomcat** | Application server | 9090 |
| **Nagios Core** | Real-time monitoring | 80 (/nagios4/) |
| **Maven** | Build tool | - |
| **Java 17** | Runtime environment | - |

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Quick Start](#quick-start)
4. [How It Works](#how-it-works)
5. [Configuration Reference](#configuration-reference)
6. [User Manual](#user-manual)
7. [Troubleshooting](#troubleshooting)
8. [Task Requirements](#task-requirements)

---

## Prerequisites

```bash
# Install Ansible
sudo apt update
sudo apt install ansible -y

# Install Nagios Core
sudo apt install nagios4 nagios-plugins -y
```

---

## Project Structure

```
task-02/
├── README.md
├── Jenkinsfile
├── diagram.drawio
├── scripts/
│   └── build.sh
└── ansible/
    ├── group_vars/all.yml        # ★ All variables
    ├── tomcat.yml
    ├── jenkins.yml
    ├── nagios.yml
    ├── petclinic.yml
    └── roles/
        ├── tomcat/
        │   └── templates/
        │       ├── server.xml.j2       # ★ Port 9090
        │       └── tomcat-users.xml.j2 # ★ Admin credentials
        ├── jenkins/
        ├── petclinic/
        │   ├── tasks/main.yml          # ★ ServletInitializer
        │   └── handlers/main.yml       # ★ JENKINS_NODE_COOKIE
        └── nagios/
            └── templates/
                ├── tomcat_commands.cfg.j2  # ★ check_http, check_tcp
                └── tomcat_host.cfg.j2      # ★ Services definition
```

---

## Quick Start

```bash
cd /home/amal/task-02/ansible

# 1. Install Tomcat
ansible-playbook tomcat.yml

# 2. Build and deploy PetClinic
ansible-playbook petclinic.yml

# 3. Configure Nagios monitoring
ansible-playbook nagios.yml --ask-become-pass
```

**Access:**
- PetClinic: http://localhost:9090/petclinic/
- Nagios: http://localhost/nagios4/

---

## How It Works


### Jenkinsfile Stages

| Stage | Command |
|-------|---------|
| Build & Deploy | `ansible-playbook petclinic.yml` |
| Verify Deployment | `curl localhost:9090/petclinic/` |
| Verify Monitoring | `check_http`, `check_tcp` |

### Critical Configurations

#### 1. ServletInitializer.java
Allows Spring Boot to run as WAR in Tomcat (instead of JAR):
```java
public class ServletInitializer extends SpringBootServletInitializer {
    protected SpringApplicationBuilder configure(SpringApplicationBuilder app) {
        return app.sources(PetClinicApplication.class);
    }
}
```

#### 2. JENKINS_NODE_COOKIE
Prevents Jenkins from killing Tomcat after pipeline:
```bash
export JENKINS_NODE_COOKIE=dontKillMe
```

#### 3. Real Nagios Plugins
Uses built-in Nagios plugins (not custom scripts):
```bash
/usr/lib/nagios/plugins/check_http -H 127.0.0.1 -p 9090
/usr/lib/nagios/plugins/check_tcp -H 127.0.0.1 -p 9090
```

---

## Configuration Reference

### group_vars/all.yml

| Variable | Value |
|----------|-------|
| `tomcat_port` | 9090 |
| `jenkins_port` | 8080 |
| `tomcat_manager_user` | admin |
| `tomcat_manager_password` | admin123 |
| `nagios_core_etc` | /etc/nagios4 |
| `nagios_core_plugins` | /usr/lib/nagios/plugins |

---

## User Manual

### Start/Stop Services

```bash
# Tomcat
/home/amal/devops/tomcat/bin/startup.sh
/home/amal/devops/tomcat/bin/shutdown.sh

# Jenkins
/home/amal/devops/jenkins/start.sh
/home/amal/devops/jenkins/stop.sh

# Nagios
sudo systemctl start nagios4
sudo systemctl stop nagios4
```

### Web Access

| Application | URL | Credentials |
|-------------|-----|-------------|
| PetClinic | http://localhost:9090/petclinic/ | None |
| Tomcat Manager | http://localhost:9090/manager/html | admin / admin123 |
| Jenkins | http://localhost:8080 | Initial password in logs |
| Nagios | http://localhost/nagios4/ | nagiosadmin |

### Jenkins Pipeline Setup

1. Open http://localhost:8080
2. Create new **Pipeline** job
3. Set **Repository URL:** `/home/amal/task-02`
4. Set **Script Path:** `Jenkinsfile`
5. Click **Build Now**

### Nagios Monitoring

Services monitored every 1 minute:
- Tomcat HTTP
- Tomcat TCP Port
- PetClinic Application
- Tomcat Manager

Test by stopping Tomcat → services show CRITICAL in Nagios UI.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| PetClinic not accessible | Check `tail -50 /home/amal/devops/tomcat/logs/catalina.out` |
| Tomcat stops after pipeline | Ensure `JENKINS_NODE_COOKIE=dontKillMe` in handler |
| Nagios playbook needs sudo | Run with `--ask-become-pass` |
| Nagios UNKNOWN status | Run `sudo /usr/sbin/nagios4 -v /etc/nagios4/nagios.cfg` |

---

