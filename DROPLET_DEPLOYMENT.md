# Deploy to DigitalOcean Droplet

This guide will help you deploy the Chuck Norris Flask API to a DigitalOcean Droplet using Docker.

## Prerequisites

1. **DigitalOcean Account** with API access
2. **SSH Key** configured for Droplet access
3. **Smallest Droplet**: Basic plan - 1GB RAM, 1 vCPU, 25GB SSD ($4/month)

## Quick Deployment Steps

### 1. Create a Droplet in NYC

Using DigitalOcean CLI (doctl):
```bash
# Create smallest droplet in NYC region
doctl compute droplet create chuck-norris-api \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --region nyc1 \
  --ssh-keys <your-ssh-key-id>
```

Or via the DigitalOcean web console:
- **Image**: Ubuntu 22.04 LTS
- **Plan**: Basic - $4/month (1GB RAM, 1 vCPU, 25GB SSD)
- **Region**: New York 1 (NYC1)
- **Authentication**: Add your SSH key

### 2. Deploy the Application

Once your Droplet is running, use the deployment script:

```bash
# Get your Droplet's IP address
DROPLET_IP="YOUR_DROPLET_IP"

# Run deployment script
./deploy-to-droplet.sh $DROPLET_IP ~/.ssh/id_rsa
```

### 3. Verify Deployment

After deployment completes:
- Visit `http://YOUR_DROPLET_IP:8080` to see your API
- The API serves Chuck Norris jokes at the root endpoint

## Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
# SSH into your Droplet
ssh root@YOUR_DROPLET_IP

# Clone or upload your project
git clone https://github.com/do-community/do-one-click-deploy-flask.git
cd do-one-click-deploy-flask

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Build and run
docker-compose up -d --build

# Open firewall port
ufw allow 8080
```

## Droplet Management

### View application status:
```bash
ssh root@YOUR_DROPLET_IP
cd /opt/chuck-norris-api
docker-compose ps
```

### View logs:
```bash
docker-compose logs -f
```

### Restart application:
```bash
docker-compose restart
```

### Stop application:
```bash
docker-compose down
```

### Update application:
```bash
# Pull latest changes
git pull origin main
# Rebuild and restart
docker-compose up -d --build
```

## Cost Comparison

| Service | Cost | Specs | Management |
|---------|------|-------|------------|
| **Droplet** | $4/month | 1GB RAM, 1 vCPU | Manual |
| **App Platform** | $5/month | 0.5GB RAM, 1 vCPU | Managed |

The Droplet costs $1 less per month but requires manual server management, while App Platform provides automatic scaling, health checks, and managed infrastructure.

## Security Notes

- The deployment script automatically configures UFW firewall
- Only ports 22 (SSH) and 8080 (API) are opened
- Consider using a reverse proxy (nginx) with SSL for production
- Regular security updates should be applied to the Ubuntu system