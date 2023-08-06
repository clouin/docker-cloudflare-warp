# docker-cloudflare-warp

该项目提供了一个用于在代理模式下运行 Cloudflare Warp 的 Docker 镜像。

## 使用方法

SOCKS 代理开放在端口 `1080`。

您可以使用以下环境变量：

* `FAMILIES_MODE`：可选值为 `off`、`malware` 和 `full`。（默认值：`off`）
* `WARP_LICENSE`：填入您的 WARP+ 许可证。（您可以从这个 Telegram 机器人获取免费的 WARP+
  许可证：[https://t.me/generatewarpplusbot](https://t.me/generatewarpplusbot)）

### 运行

```
docker run -d --name=cloudflare-warp -p 1080:1080 -e WARP_LICENSE=xxxxxxxx-xxxxxxxx-xxxxxxxx -v ${PWD}/warp:/var/lib/cloudflare-warp --restart=unless-stopped jerryin/cloudflare-warp
```

#### 使用 `warp-cli` 命令来控制您的连接

```
docker exec cloudflare-warp warp-cli --accept-tos status

Status update: Connected
Success
```

#### 通过访问此 URL 来验证 Warp

```
curl -x socks5://127.0.0.1:1080 -sL https://cloudflare.com/cdn-cgi/trace | grep warp

warp=plus
```

#### 查找您的 Warp IP 位置

```
curl -s -x socks5://127.0.0.1:1080 https://ipinfo.io
```

#### 速度测试

```
curl -x socks5://127.0.0.1:1080 https://speed.cloudflare.com/__down?bytes=1000000000 > /dev/null
```

### 使用 docker-compose

```yaml
version: "3.8"

services:
  warp:
    image: jerryin/cloudflare-warp
    container_name: cloudflare-warp
    restart: unless-stopped
    ports:
      - "1080:1080"
    environment:
      WARP_LICENSE: xxxxxxxx-xxxxxxxx-xxxxxxxx
      FAMILIES_MODE: off
    volumes:
      - ./warp:/var/lib/cloudflare-warp
```

## 与`Xray`服务端一起使用

### docker-compose

```
version: "3.8"

services:
  warp:
    image: jerryin/cloudflare-warp
    restart: unless-stopped
    expose:
      - "1080"
    environment:
      WARP_LICENSE: xxxxxxxx-xxxxxxxx-xxxxxxxx
      FAMILIES_MODE: off
    volumes:
      - ./warp:/var/lib/cloudflare-warp
  xray:
    depends_on:
      - warp
    image: teddysun/xray
    restart: unless-stopped
    ports:
      - "1080:1080"
    volumes:
      - ./xray:/etc/xray
```

### xray配置

- 配置文件路径：`./xray/config.json`
- 配置文件样例：

```
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 1080,
      "protocol": "vless",
      ......
      // 入站协议配置
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    },
    {
      "tag": "warp",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "warp",
            "port": 1080
          }
        ]
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "warp",
        "domain": [
          "chat.openai.com",
          "openai.com",
          "sentry.io",
          "intercom.io"
        ]
      }
    ]
  }
}
```