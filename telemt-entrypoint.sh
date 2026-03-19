# ghostway — telemt-entrypoint
#!/bin/sh
set -e

# Substitute environment variables into telemt config before start
envsubst < /run/telemt/telemt.toml.tpl > /run/telemt/telemt.toml

exec telemt /run/telemt/telemt.toml
