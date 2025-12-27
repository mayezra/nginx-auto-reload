#!/bin/sh

NGINX_CONFIG="/etc/nginx-custom/nginx.conf"
CHECK_INTERVAL=10
NGINX_PID_FILE="/var/run/nginx.pid"

echo "==================================="
echo "NGINX Config Watcher Started"
echo "Monitoring: $NGINX_CONFIG"
echo "==================================="

last_md5=$(md5sum "$NGINX_CONFIG" | cut -d' ' -f1)
echo "Initial checksum: $last_md5"

while true; do
    sleep $CHECK_INTERVAL
    
    current_md5=$(md5sum "$NGINX_CONFIG" | cut -d' ' -f1)
    
    if [ "$current_md5" != "$last_md5" ]; then
        echo "[$(date)] Config changed detected!"
        
        if nginx -t -c "$NGINX_CONFIG" 2>&1; then
            echo "Config valid, reloading NGINX..."
            
            # Use kill -HUP instead of nginx -s reload
            if [ -f "$NGINX_PID_FILE" ]; then
                nginx_pid=$(cat "$NGINX_PID_FILE")
                echo "Sending HUP signal to NGINX (PID: $nginx_pid)"
                kill -HUP "$nginx_pid" && echo "✓ Reload successful"
            else
                echo "WARNING: PID file not found, trying nginx -s reload"
                nginx -s reload && echo "✓ Reload successful"
            fi
            
            last_md5=$current_md5
        else
            echo "✗ Config invalid, skipping reload"
        fi
    fi
done
