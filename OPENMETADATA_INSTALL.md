# OpenMetadata Installation on EC2

## Prerequisites

- Amazon Linux 2 EC2 instance
- Sufficient storage (expand if needed)

## Installation Steps

### 1. Install Docker

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
exit  # Re-login for group changes
```

### 2. Install Docker Compose

```bash
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
sudo systemctl restart docker
```

### 3. Deploy OpenMetadata

```bash
mkdir ~/openmetadata-docker && cd ~/openmetadata-docker
curl -sL -o docker-compose.yml https://github.com/open-metadata/OpenMetadata/releases/download/1.9.12-release/docker-compose.yml
docker compose up --detach
```

### 4. Create Systemd Service

Create `/etc/systemd/system/om-ai.service`:

```ini
[Unit]
Description=OpenMetadata Docker Compose Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/openmetadata-docker
ExecStart=/usr/libexec/docker/cli-plugins/docker-compose up -d
ExecStop=/usr/libexec/docker/cli-plugins/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable service:

```bash
sudo chmod 644 /etc/systemd/system/om-ai.service
sudo systemctl daemon-reload
sudo systemctl enable --now om-ai.service
```

### 5. Expand Storage (if needed)

```bash
sudo growpart /dev/nvme0n1 1
sudo xfs_growfs -d /
```

## Management Commands

```bash
docker ps                      # Check containers
docker compose restart         # Restart all
docker logs <container_id>     # View logs
sudo systemctl status om-ai.service  # Check service status
```
