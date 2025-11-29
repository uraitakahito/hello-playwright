## Setup

Please download the required files by following these steps:

```
curl -L -O https://raw.githubusercontent.com/uraitakahito/hello-javascript/refs/heads/main/docker-entrypoint.sh
chmod 755 docker-entrypoint.sh
```

**Detailed environment setup instructions are described at the beginning of the `Dockerfile`.**

## Connecting to the Server

There are two ways to connect to the remote Playwright server:

1. Using environment variable:

```
PW_WS_ENDPOINT=ws://playwright:3000/ node src/index.js
```

2. Using the browserType.connect() API for other applications:

```
const browser = await playwright['chromium'].connect('ws://127.0.0.1:3000/');
```
