# ghostway — xray-entrypoint
#!/bin/sh
set -e

# Substitute environment variables into xray config before start
envsubst < /etc/xray/config.json.tpl > /etc/xray/config.json

exec xray run -config /etc/xray/config.json
