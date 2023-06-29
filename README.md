# docker-cloudflare-warp

Docker image for running Cloudflare Warp in proxy mode.

## Usage

The socks proxy is exposed on port `1080`.

You can use these environment variables:

* `FAMILIES_MODE`: Use one of the `off`, `malware`, and `full` values. (Default: `off`)
* `WARP_LICENSE`: Put your WARP+ license. (You can get a free WARP+ license from this Telegram bot: [https://t.me/generatewarpplusbot](https://t.me/generatewarpplusbot))

### Run

```
docker run -d --name=cloudflare-warp -p 127.0.0.1:1080:1080 -e WARP_LICENSE=xxxxxxxx-xxxxxxxx-xxxxxxxx -v ${PWD}/warp:/var/lib/cloudflare-warp --restart=unless-stopped jerryin/cloudflare-warp
```

#### You can use the `warp-cli` command to control your connection

```
docker exec cloudflare-warp warp-cli --accept-tos status

Status update: Connected
Success
```

#### You can verify Warp by visiting this URL

```
curl -x socks5://127.0.0.1:1080 -sL https://cloudflare.com/cdn-cgi/trace | grep warp

warp=plus
```

#### Lookup your Warp IP location

```
curl -s -x socks5://127.0.0.1:1080 https://ipinfo.io
```

#### Speedtest

```
curl -x socks5://127.0.0.1:1080 https://speed.cloudflare.com/__down?bytes=1000000000 > /dev/null
```

### docker-compose

```yaml
version: "3.8"

services:
  warp:
    image: jerryin/cloudflare-warp
    container_name: cloudflare-warp
    restart: unless-stopped
    ports:
      - "127.0.0.1:1080:1080"
    environment:
      WARP_LICENSE: xxxxxxxx-xxxxxxxx-xxxxxxxx
      FAMILIES_MODE: off
    volumes:
      - ./warp:/var/lib/cloudflare-warp
```