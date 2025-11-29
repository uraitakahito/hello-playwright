## Setup

Please download the required files by following these steps:

```
curl -L -O https://raw.githubusercontent.com/uraitakahito/hello-javascript/refs/heads/main/docker-entrypoint.sh
chmod 755 docker-entrypoint.sh
```

**Detailed environment setup instructions are described at the beginning of the `Dockerfile`.**

## Examples

```bash
node src/index.js --endpoint ws://playwright:3000/ --url https://example.com
```
