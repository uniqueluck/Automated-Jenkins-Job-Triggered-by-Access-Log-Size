
# 📦 Automated Jenkins Job Triggered by Access Log Size

This project demonstrates how to automate log file management by monitoring the size of an access log file on an EC2 instance. When the file exceeds 1GB, a Jenkins job is triggered automatically to upload the log file to an AWS S3 bucket and clear the original file.

Perfect for **beginners** who want to practice AWS, Jenkins, and shell scripting.

---

## 📑 Table of Contents

- [🚀 Why This Project?](#-why-this-project)
- [🎯 What You Will Learn](#-what-you-will-learn)
- [🖥️ Architecture Overview](#-architecture-overview)
- [📝 Prerequisites](#-prerequisites)
- [⚙️ Step-by-Step Guide](#️-step-by-step-guide)
  - [1️⃣ Launch EC2 Instance](#1️⃣-launch-ec2-instance)
  - [2️⃣ Install and Configure Jenkins](#2️⃣-install-and-configure-jenkins)
  - [3️⃣ Configure AWS CLI](#3️⃣-configure-aws-cli)
  - [4️⃣ Create an S3 Bucket](#4️⃣-create-an-s3-bucket)
  - [5️⃣ Write log_monitor.sh Script](#5️⃣-write-log_monitorsh-script)
  - [6️⃣ Schedule Cron Job](#6️⃣-schedule-cron-job)
  - [7️⃣ Create Jenkins Job](#7️⃣-create-jenkins-job)
  - [8️⃣ Trigger Jenkins Job](#8️⃣-trigger-jenkins-job)
  - [9️⃣ Verify Jenkins Console Output](#9️⃣-verify-jenkins-console-output)
  - [🔟 Verify S3 Upload](#🔟-verify-s3-upload)
  - [1️⃣1️⃣ Confirm Cleared Log File](#1️⃣1️⃣-confirm-cleared-log-file)
- [📂 Project Deliverables](#-project-deliverables)
- [🏆 Outcome](#-outcome)

---

## 🚀 Why This Project?

- 📝 Prevents disk space issues by automating log management.
- 📦 Integrates **EC2, Jenkins, AWS S3, and shell scripts** into a single workflow.
- 👩‍💻 Great for students and freshers to learn **DevOps practices** step-by-step.
- 📁 Real-world use case to add to your resume or GitHub portfolio.

---

## 🎯 What You Will Learn

✅ Monitor log file size with a shell script  
✅ Trigger Jenkins jobs remotely using REST API  
✅ Upload files to AWS S3 from Jenkins  
✅ Automate tasks using cron jobs  
✅ Handle permissions between Jenkins and EC2

---

## 🖥️ Architecture Overview

```
+-------------------------+     Trigger (if >1GB)     +---------------+
| EC2 Instance            |-------------------------->| Jenkins Job   |
| log_monitor.sh (cron)   |                           | upload-to-s3  |
+-------------------------+                           +---------------+
        |                                                        |
        |                                                        v
        |---------------------------------------------> AWS S3 Bucket
                          Upload & Clear
```

📸 **Screenshot: Architecture Diagram**  
![Architecture Diagram](screenshots/architecture-diagram.png)

---


- 📝 Prevents disk space issues by automating log management.
- 📦 Integrates **EC2, Jenkins, AWS S3, and shell scripts** into a single workflow.
- 👩‍💻 Great for students and freshers to learn **DevOps practices** step-by-step.
- 📁 Real-world use case to add to your resume or GitHub portfolio.

---


## 📝 Prerequisites

- AWS Account with S3 access  
- IAM User with S3 permissions  
- EC2 Instance (Amazon Linux 2)  
- Jenkins installed and running on EC2  
- AWS CLI configured on EC2  
- S3 bucket created  

---

## ⚙️ Step-by-Step Guide

### 1️⃣ Launch EC2 Instance

Launch an Amazon Linux  EC2 instance.

SSH into the instance.

📸 **Screenshot: EC2 Instance Details**  
![EC2 Instance](screenshots/ec2-instance.png)

---

### 2️⃣ Install and Configure Jenkins

- SSH into your EC2 instance.  
- Install Jenkins and start the service:  
```bash
sudo yum update -y
sudo yum install java-11-openjdk -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
```
- Access Jenkins in browser: `http://<EC2_PUBLIC_IP>:8080`  

📸 **Screenshot: Jenkins Dashboard**  
![Jenkins Dashboard](screenshots/jenkins-dashboard.png)

---

### 3️⃣ Configure AWS CLI

Configure AWS CLI on your EC2 instance:  
```bash
aws configure
```
📸 **Screenshot: AWS CLI Configuration**  
![AWS CLI Configure](screenshots/aws-cli-configure.png)

---

### 4️⃣ Create an S3 Bucket

Go to AWS S3 Console → Create a bucket (e.g., `access-log-backup-bucket`).  

📸 **Screenshot: S3 Bucket Created**  
![S3 Bucket](screenshots/s3-bucket-created.png)

---

### 5️⃣ Write `log_monitor.sh` Script

This script monitors log file size and triggers the Jenkins job.

📄 **log_monitor.sh**
```bash
#!/bin/bash
LOG_FILE="/var/lib/jenkins/access.log"
JENKINS_URL="http://<your-jenkins-url>:8080"
JENKINS_USER="your_username"
JENKINS_API_TOKEN="your_token"
JOB_NAME="upload-to-s3"
CRUMB=$(curl -s -u $JENKINS_USER:$JENKINS_API_TOKEN "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)")

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file does not exist: $LOG_FILE"
    exit 1
fi

FILE_SIZE=$(stat -c%s "$LOG_FILE")
if [ $FILE_SIZE -gt 1073741824 ]; then
    echo "File size exceeds 1GB. Triggering Jenkins job..."
    curl -X POST "$JENKINS_URL/job/$JOB_NAME/build"          -u $JENKINS_USER:$JENKINS_API_TOKEN          -H "$CRUMB"
else
    echo "File size is under limit. No action needed."
fi
```

📸 **Screenshot: log_monitor.sh**  
![Log Monitor Script](screenshots/log-monitor-script.png)

---

### 6️⃣ Schedule Cron Job

Run `crontab -e` and add this line:  
```
*/5 * * * * /home/ec2-user/log_monitor.sh >> /home/ec2-user/monitor.log 2>&1
```

📸 **Screenshot: Cron Job Configuration**  
![Cron Job](screenshots/cron-job-configuration.png)

---

### 7️⃣ Create Jenkins Job

#### 📌 General Tab
Name the job: `upload-to-s3`  
📸 **Screenshot: Jenkins General Tab**  
![General Tab](screenshots/jenkins-general-tab-settings.png)

#### 📌 Build Triggers
Enable: “Trigger builds remotely”  
Token: `monitoring-script-token`  
📸 **Screenshot: Jenkins Build Trigger Settings**  
![Build Trigger](screenshots/jenkins-build-trigger-settings.png)

#### 📌 Build Step
Add **Execute Shell** step:  
```bash
#!/bin/bash
LOG_FILE="/var/lib/jenkins/access.log"
BUCKET_NAME="access-log-backup-bucket"
aws s3 cp $LOG_FILE s3://$BUCKET_NAME/
if [ $? -eq 0 ]; then
    echo "Upload successful. Clearing log file..."
    > $LOG_FILE
else
    echo "Upload failed."
    exit 1
fi
```
📸 **Screenshot: Jenkins Execute Shell**  
![Execute Shell](screenshots/jenkins-execute-shell-configuration.png)

---

### 8️⃣ Trigger Jenkins Job

When log file exceeds 1GB, it triggers the Jenkins job automatically.  

📸 **Screenshot: log_monitor.sh Trigger Output**  
![Trigger Jenkins](screenshots/log-monitor-triggering-jenkins.png)

---

### 9️⃣ Verify Jenkins Console Output

Check Jenkins build logs for successful upload.  

📸 **Screenshot: Jenkins Console Log**  
![Console Log](screenshots/jenkins-build-console-log.png)

---

### 🔟 Verify S3 Upload

Check S3 bucket for the uploaded log file.  

📸 **Screenshot: S3 Upload**  
![S3 Upload](screenshots/s3-bucket-upload.png)

---

### 1️⃣1️⃣ Confirm Cleared Log File

After successful upload, verify log file is cleared.  

📸 **Screenshot: Cleared Log File**  
![Cleared Log](screenshots/cleared-log-file-confirmation.png)

---

## 📂 Project Deliverables

- ✅ Shell script: `log_monitor.sh`
- ✅ Jenkins Freestyle Job: `upload-to-s3`
- ✅ Proof of upload and cleared log file (screenshots)
- ✅ Beginner-friendly documentation

---

## 🏆 Outcome

By completing this project, you’ll gain practical experience in:  
- Automating server tasks with shell scripts.
- Integrating Jenkins with AWS.
- Building pipelines for real-world use cases.

Perfect to showcase as a **DevOps mini-project** on your resume or GitHub profile.

