# ghostway — caddy-entrypoint
#!/bin/sh
set -e

SNIPPETS_DIR=/etc/caddy/snippets
CONFIG_DIR=/etc/caddy

if [ "$MASK_MODE" = "proxy" ]; then
    cp "$SNIPPETS_DIR/mask.proxy.caddy" "$CONFIG_DIR/mask.caddy"
    echo "[entrypoint] mask mode: proxy -> $MASK_PROXY_TARGET"
else
    cp "$SNIPPETS_DIR/mask.static.caddy" "$CONFIG_DIR/mask.caddy"
    echo "[entrypoint] mask mode: static"
fi

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
