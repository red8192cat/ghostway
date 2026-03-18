# ghostway

> Invisible MTProxy stack: FakeTLS → VLESS+Reality → Telegram

```
User (Telegram) → telemt:443 (FakeTLS) → xray (VLESS+Reality) → Telegram DC
Crawler / DPI   → telemt:443           → Caddy (real HTTPS site, valid cert)
```

- **telemt** — MTProxy with FakeTLS masking, owns port 443
- **xray-core** — VLESS+Reality client, internal only (no exposed ports)
- **Caddy** — serves stub site to crawlers, auto-renews Let's Encrypt cert

## Requirements

- Linux server with Docker and Docker Compose v2
- Domain with A-record pointing to this server
- A running xray-core server with VLESS+Reality configured

## Quick start

```bash
git clone https://github.com/YOUR_ORG/ghostway
cd ghostway
cp .env.example .env
nano .env          # fill in your values
docker compose up -d
```

Get your Telegram proxy link:

```bash
curl -s http://127.0.0.1:9091/v1/users | jq '.[].links'
```

## Configuration

Everything lives in `.env`:

| Variable | Description |
|---|---|
| `DOMAIN` | Your domain (A-record → this server) |
| `PROXY_SECRET` | MTProxy secret — run `openssl rand -hex 16` |
| `XRAY_SERVER_IP` | xray-server IP |
| `XRAY_SERVER_PORT` | xray-server port (usually 443) |
| `XRAY_UUID` | VLESS user UUID |
| `XRAY_SNI` | Reality SNI domain |
| `XRAY_PUBLIC_KEY` | Reality public key |
| `XRAY_SHORT_ID` | Reality short ID |
| `MASK_MODE` | `static` (default) or `proxy` |
| `MASK_PROXY_TARGET` | Used when `MASK_MODE=proxy`, e.g. `https://en.wikipedia.org` |

### Stub site modes

**Static page** (default) — serves `site/index.html`:
```env
MASK_MODE=static
```

**Reverse proxy** — forwards crawlers to a real site:
```env
MASK_MODE=proxy
MASK_PROXY_TARGET=https://en.wikipedia.org
```

**Local nginx** — another container in the same Docker network:
```env
MASK_MODE=proxy
MASK_PROXY_TARGET=http://nginx:80
```

Switch mode without full restart:
```bash
# edit .env, then:
docker compose restart caddy
```

## How it works

1. Everything external hits **telemt on port 443**.
2. If the connection carries a valid MTProxy handshake → traffic goes to **xray** via internal SOCKS5, then out through **VLESS+Reality** to the Telegram DC.
3. If not (crawler, browser, DPI probe) → **TCP-splice** to **Caddy on port 8443** (internal only). The visitor gets a real HTTPS response with a valid Let's Encrypt certificate.
4. **Caddy** renews the certificate automatically in the background — no restarts needed.

## Useful commands

```bash
# Start
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Restart single service
docker compose restart caddy

# Stop everything (keeps volumes)
docker compose down

# Get proxy links
curl -s http://127.0.0.1:9091/v1/users | jq '.[].links'
```

## File structure

```
ghostway/
├── .env                    ← the only file you need to edit
├── docker-compose.yml
├── Caddyfile
├── telemt.toml
├── xray.json
├── caddy-entrypoint.sh
├── xray-entrypoint.sh
├── telemt-entrypoint.sh
├── mask.static.caddy
├── mask.proxy.caddy
└── site/
    └── index.html          ← replace with your own stub page
```
