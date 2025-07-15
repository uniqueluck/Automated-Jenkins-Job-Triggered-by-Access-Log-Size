#!/bin/bash

LOG_FILE="/var/lib/jenkins/access.log"
BUCKET_NAME="your_s3_bucket_name"
JENKINS_URL="http://<your-jenkins-url>:8080"
JENKINS_JOB="upload-to-s3"
JENKINS_USER="your_username"
JENKINS_API_TOKEN="your_api_token"
TRIGGER_TOKEN="your_trigger_token_name"
MAX_SIZE=$((1024 * 1024 * 1024)) # 1GB

# === LOG FUNCTION ===
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "===== Starting log_monitor.sh ====="

# === CHECK IF LOG FILE EXISTS ===
if [ ! -f "$LOG_FILE" ]; then
    log "❌ Log file $LOG_FILE does not exist. Exiting."
    exit 1
fi

# === GET FILE SIZE ===
FILE_SIZE=$(stat -c%s "$LOG_FILE")
log "Current file size: $FILE_SIZE bytes"

# === COMPARE FILE SIZE ===
if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
    log "📦 File size exceeds 1GB. Triggering Jenkins job..."

    # Trigger Jenkins job using token
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u $JENKINS_USER:$JENKINS_API_TOKEN \
    "$JENKINS_URL/job/$JENKINS_JOB/build?token=$TRIGGER_TOKEN")

    # Check response
    if [ "$HTTP_CODE" -eq 201 ]; then
        log "✅ Jenkins job triggered successfully (HTTP $HTTP_CODE)"
    else
        log "❌ Failed to trigger Jenkins job (HTTP $HTTP_CODE)"
        exit 1
    fi
else
    log "ℹ️ File size is under limit. No action needed."
fi

log "===== Finished log_monitor.sh ====="
