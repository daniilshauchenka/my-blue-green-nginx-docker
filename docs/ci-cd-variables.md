# GitLab CI/CD Variables

| Variable               | Description                          | Example                               | Protected | Masked |
| ---------------------- | ------------------------------------ | ------------------------------------- | --------- | ------ |
| `APP_NAME`             | Application name                     | `blue-green-demo`                     | No        | No     |
| `DEPLOY_ENV`           | Deployment environment               | `dev`                                 | No        | No     |
| `DEPLOY_TIMEOUT`       | Deployment timeout in seconds        | `60`                                  | No        | No     |
| `HEALTHCHECK_PATH`     | Application healthcheck endpoint     | `/inner/healthcheck`                  | No        | No     |
| `REGISTRY_HOST`        | Docker registry host                 | `34.xxx.xxx.xxx:5000`                 | Yes       | No     |
| `REGISTRY_IMAGE`       | Full Docker image path               | `34.xxx.xxx.xxx:5000/app`             | Yes       | No     |
| `DOCKER_BUILDKIT`      | Enable Docker BuildKit               | `1`                                   | No        | No     |
| `COMPOSE_PROJECT_NAME` | Docker Compose project name          | `blue-green`                          | No        | No     |
| `NGINX_PORT`           | External nginx port                  | `80`                                  | No        | No     |
| `RUNTIME_HOST`         | Runtime VM IP address                | `34.xxx.xxx.xxx`                      | Yes       | No     |
| `RUNTIME_PATH`         | Blue-green runtime directory         | `/opt/blue-green`                     | No        | No     |
| `RUNTIME_USER`         | SSH deploy user                      | `deploy`                              | Yes       | No     |
| `SSH_PRIVATE_KEY`      | SSH private key used for deployment  | `-----BEGIN OPENSSH PRIVATE KEY-----` | Yes       | Yes    |
| `TELEGRAM_BOT_TOKEN`   | Telegram bot token for notifications | `123456:ABC...`                       | Yes       | Yes    |
| `TELEGRAM_CHAT_ID`     | Telegram chat ID for notifications   | `123456789`                           | Yes       | No     |

---