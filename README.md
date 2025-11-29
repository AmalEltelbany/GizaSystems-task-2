# DevOps Internship - Task 2: Automated Deployment with Ansible

## Overview

This project demonstrates automated infrastructure setup and application deployment using Ansible, shell scripting, and Jenkins CI/CD pipeline. The Spring PetClinic application is built and deployed to Apache Tomcat with Nagios monitoring.

## Project Structure

```
task-02/
├── README.md
├── Jenkinsfile                    # CI/CD Pipeline definition
├── scripts/
│   └── build.sh                   # Shell script to build PetClinic WAR
└── ansible/
    ├── ansible.cfg                # Ansible configuration
    ├── inventory/
    │   └── hosts                  # Inventory file (localhost)
    ├── group_vars/
    │   └── all.yml                # Global variables
    ├── tomcat.yml                 # Tomcat installation playbook
    ├── jenkins.yml                # Jenkins installation playbook
    ├── nagios.yml                 # Nagios installation playbook
    ├── petclinic.yml              # PetClinic build & deploy playbook
    └── roles/
        ├── tomcat/
        │   ├── tasks/main.yml
        │   └── templates/
        │       ├── server.xml.j2
        │       ├── tomcat-users.xml.j2
        │       ├── context.xml.j2
        │       ├── start.sh.j2
        │       └── stop.sh.j2
        ├── jenkins/
        │   ├── tasks/main.yml
        │   └── templates/
        │       ├── start.sh.j2
        │       └── stop.sh.j2
        ├── nagios/
        │   ├── tasks/main.yml
        │   └── templates/
        │       ├── check_tomcat.sh.j2
        │       ├── nagios.cfg.j2
        │       └── monitor.sh.j2
        └── petclinic/
            ├── tasks/main.yml
            └── handlers/main.yml
```

## Prerequisites

- Linux-based operating system
- Ansible installed (only step where package manager is allowed)
- Internet connection to download dependencies

## Task Requirements Completed

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| Install Ansible using package manager | ✅ | `sudo apt install ansible` |
| Install Tomcat using Ansible | ✅ | `ansible/tomcat.yml` |
| Configure Tomcat deployment manager | ✅ | `tomcat-users.xml.j2`, `context.xml.j2` |
| Install Nagios using Ansible | ✅ | `ansible/nagios.yml` |
| Install Jenkins using Ansible | ✅ | `ansible/jenkins.yml` |
| Build PetClinic using shell script | ✅ | `scripts/build.sh` |
| Deploy PetClinic using Ansible | ✅ | `ansible/petclinic.yml` |
| Automated sanity checks | ✅ | HTTP check in `petclinic.yml` |
| Nagios monitors Tomcat | ✅ | `check_tomcat.sh.j2` |
| Application on port 9090 | ✅ | Configured in `group_vars/all.yml` |
| Jenkinsfile for CI/CD | ✅ | `Jenkinsfile` |
| No package managers (except Ansible) | ✅ | All tools downloaded as archives |

## Installation Steps

### Step 1: Install Ansible (Root/Package Manager Allowed)

```bash
sudo apt update
sudo apt install ansible -y
```

### Step 2: Clone This Repository

```bash
git clone https://github.com/YOUR_USERNAME/devops-task2.git
cd devops-task2
```

### Step 3: Install Tomcat

```bash
cd ansible
ansible-playbook tomcat.yml
```

This will:
- Download Apache Tomcat 10.1.18
- Configure server on port 9090
- Set up deployment manager access
- Create start/stop scripts

### Step 4: Install Jenkins

```bash
ansible-playbook jenkins.yml
```

This will:
- Download Jenkins WAR file
- Configure Jenkins on port 8080
- Create start/stop scripts

### Step 5: Install Nagios Monitoring

```bash
ansible-playbook nagios.yml
```

This will:
- Set up Nagios configuration
- Create Tomcat health check script
- Configure monitoring for port 9090

### Step 6: Build and Deploy PetClinic

```bash
ansible-playbook petclinic.yml
```

This will:
- Download Spring PetClinic source code
- Build WAR file using Maven
- Deploy to Tomcat
- Run sanity checks to verify deployment

## Configuration

All configuration is centralized in `ansible/group_vars/all.yml`:

| Variable | Value | Description |
|----------|-------|-------------|
| `tomcat_port` | 9090 | Application port |
| `tomcat_version` | 10.1.18 | Tomcat version |
| `jenkins_port` | 8080 | Jenkins port |
| `java_version` | 17.0.9 | Java JDK version |
| `maven_version` | 3.9.6 | Maven version |

## Usage

### Start Services

```bash
# Start Tomcat
/home/amal/devops/tomcat/bin/startup.sh

# Start Jenkins
/home/amal/devops/jenkins/start.sh
```

### Stop Services

```bash
# Stop Tomcat
/home/amal/devops/tomcat/bin/shutdown.sh

# Stop Jenkins
/home/amal/devops/jenkins/stop.sh
```

### Access Applications

| Application | URL |
|-------------|-----|
| PetClinic | http://localhost:9090/petclinic |
| Tomcat Manager | http://localhost:9090/manager/html |
| Jenkins | http://localhost:8080 |

### Run Nagios Health Check

```bash
/home/amal/devops/nagios/bin/check_tomcat.sh
```

Output:
- `OK - Tomcat is running on port 9090` (exit code 0)
- `CRITICAL - Tomcat is not responding on port 9090` (exit code 2)

## Build Script

The `scripts/build.sh` shell script handles WAR file generation:

```bash
./scripts/build.sh
```

What it does:
1. Sets up Java and Maven environment
2. Navigates to PetClinic source directory
3. Runs Maven package command
4. Generates WAR file in `target/` directory

## Jenkins Pipeline

The `Jenkinsfile` defines 4 stages:

1. **Clone** - Fetches PetClinic source from GitHub
2. **Build** - Compiles and packages WAR file
3. **Deploy** - Copies WAR to Tomcat webapps
4. **Verify** - Runs sanity check on deployed application

To run the pipeline:
1. Access Jenkins at http://localhost:8080
2. Create a new Pipeline job
3. Point to this repository's Jenkinsfile
4. Click "Build Now"

## Sanity Checks

Automated verification is performed after deployment:

```yaml
# From petclinic.yml
- name: Check PetClinic is accessible
  uri:
    url: "http://localhost:9090/petclinic"
    status_code: 200
  retries: 5
  delay: 5
```

This ensures the application responds with HTTP 200 before marking deployment complete.

## Nagios Monitoring

The Nagios check script monitors Tomcat availability:

```bash
# Check script location
/home/amal/devops/nagios/bin/check_tomcat.sh

# Exit codes follow Nagios convention:
# 0 = OK
# 2 = CRITICAL
```

## Key Design Decisions

1. **No Package Managers**: All tools (Java, Maven, Tomcat, Jenkins) are downloaded as archives and extracted manually via Ansible.

2. **Tomcat 10.1.x**: Using Tomcat 10 for Jakarta EE compatibility with Spring Boot 3.x.

3. **Port 9090**: As required, the application runs on port 9090 instead of default 8080.

4. **Centralized Variables**: All paths and versions are defined in `group_vars/all.yml` for easy modification.

5. **Idempotent Playbooks**: All Ansible playbooks can be run multiple times safely.

## Troubleshooting

### PetClinic not accessible
```bash
# Check if Tomcat is running
curl http://localhost:9090

# Check Tomcat logs
tail -f /home/amal/devops/tomcat/logs/catalina.out
```

### Build fails
```bash
# Verify Java version
java -version  # Should be 17.x

# Verify Maven
mvn -version
```

### Jenkins not starting
```bash
# Check Jenkins log
tail -f /home/amal/devops/jenkins/jenkins.log
```

