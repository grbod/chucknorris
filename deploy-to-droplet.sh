#!/bin/bash

# Deploy Chuck Norris Flask API to DigitalOcean Droplet
# Usage: ./deploy-to-droplet.sh <droplet-ip> [ssh-key-path]

set -e

DROPLET_IP=$1
SSH_KEY=${2:-"~/.ssh/id_rsa"}

if [ -z "$DROPLET_IP" ]; then
    echo "Usage: $0 <droplet-ip> [ssh-key-path]"
    echo "Example: $0 192.168.1.100 ~/.ssh/id_rsa"
    exit 1
fi

echo "🚀 Deploying Chuck Norris Flask API to Droplet: $DROPLET_IP"

# Create deployment directory and copy files
echo "📁 Creating project directory and copying files..."
ssh -i "$SSH_KEY" root@"$DROPLET_IP" 'mkdir -p /opt/chuck-norris-api'

# Copy only necessary files
rsync -av --exclude-from='.dockerignore' \
    --exclude='venv' \
    --exclude='__pycache__' \
    --exclude='.git' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    -e "ssh -i $SSH_KEY" \
    . root@"$DROPLET_IP":/opt/chuck-norris-api/

# Install Docker and dependencies, then run the app
echo "🐳 Installing Docker and starting application..."
ssh -i "$SSH_KEY" root@"$DROPLET_IP" << 'EOF'
    # Update system
    apt update -y
    
    # Install Docker if not already installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        apt update -y
        apt install -y docker-ce
        systemctl start docker
        systemctl enable docker
    fi
    
    # Install Docker Compose if not already installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Navigate to project directory
    cd /opt/chuck-norris-api
    
    # Stop any existing containers
    docker-compose down || true
    
    # Build and start the application
    echo "Building and starting Chuck Norris API..."
    docker-compose up -d --build
    
    # Enable UFW firewall and allow necessary ports
    if command -v ufw &> /dev/null; then
        ufw --force enable
        ufw allow ssh
        ufw allow 8080
    fi
    
    echo "✅ Deployment complete!"
    echo "🌐 Your Chuck Norris API is running at: http://$(curl -s ifconfig.me):8080"
    echo "🔍 Check status with: docker-compose ps"
    echo "📋 View logs with: docker-compose logs -f"
EOF

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "Your Flask API should now be running on:"
echo "🌐 http://$DROPLET_IP:8080"
echo ""
echo "To manage your application:"
echo "ssh -i $SSH_KEY root@$DROPLET_IP"
echo "cd /opt/chuck-norris-api"
echo "docker-compose logs -f    # View logs"
echo "docker-compose restart    # Restart app"
echo "docker-compose down       # Stop app"