#!/bin/bash
# Check if Docker is installed, install if not (without apt-get update)
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing Docker..."
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
fi

# Stop and remove all existing Repocket containers
docker stop $(docker ps -q --filter ancestor=repocket/repocket) 2>/dev/null || true
docker rm $(docker ps -a -q --f
ilter ancestor=repocket/repocket) 2>/dev/null || true

# Pull and run new Repocket container
if docker pull repocket/repocket:latest; then
    docker run --name repocket -e RP_EMAIL=duyhuynh31121991@gmail.com -e RP_API_KEY=601694d2-c47f-4369-9a06-8f1b0f2618e9 -d --restart=always repocket/repocket
    if [ $? -eq 0 ]; then
        echo "Repocket container started successfully. Check status with 'docker ps' or logs with 'docker logs repocket-$(hostname)'."
    else
        echo "Failed to start Repocket container. Check logs with 'docker logs repocket-$(hostname)'."
        exit 1
    fi
else
    echo "Failed to pull repocket/repocket image. Check network or Docker Hub access."
    exit 1
fi
