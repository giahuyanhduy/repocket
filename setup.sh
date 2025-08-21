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
docker rm $(docker ps -a -q --filter ancestor=repocket/repocket) 2>/dev/null || true

# Stop and remove all existing Pawns.app containers
docker stop $(docker ps -q --filter ancestor=iproyal/pawns-cli) 2>/dev/null || true
docker rm $(docker ps -a -q --filter ancestor=iproyal/pawns-cli) 2>/dev/null || true

# Stop and remove all existing TraffMonetizer containers
docker stop $(docker ps -q --filter ancestor=traffmonetizer/cli_v2) 2>/dev/null || true
docker rm $(docker ps -a -q --filter ancestor=traffmonetizer/cli_v2) 2>/dev/null || true

# Pull and run new Repocket container
if docker pull repocket/repocket; then
    docker run -d --platform linux/amd64 --restart=unless-stopped --name repocket-$(hostname) repocket/repocket -email giahuyanhduy@gmail.com -api-key 858d4d30-6080-4cd0-8949-8d3ca06dcbb5
    if [ $? -eq 0 ]; then
        echo "Repocket container started successfully."
    else
        echo "Failed to start Repocket container. Check logs with 'docker logs repocket-$(hostname)'."
        exit 1
    fi
else
    echo "Failed to pull repocket/repocket image. Check network or Docker Hub access."
    exit 1
fi

# Pull and run new Pawns.app container
if docker pull iproyal/pawns-cli:latest; then
    docker run -d --platform linux/amd64 --restart=unless-stopped --name pawns-$(hostname) iproyal/pawns-cli:latest -email giahuyanhduy@gmail.com -password Anhduy3112 -device-name Ubuntu$(hostname) -device-id Ubuntu$(hostname) -accept-tos
    if [ $? -eq 0 ]; then
        echo "Pawns.app container started successfully."
    else
        echo "Failed to start Pawns.app container. Check logs with 'docker logs pawns-$(hostname)'."
        exit 1
    fi
else
    echo "Failed to pull iproyal/pawns-cli image. Check network or Docker Hub access."
    exit 1
fi

# Pull and run new TraffMonetizer container
if docker pull traffmonetizer/cli_v2; then
    docker run -d --platform linux/amd64 --restart=unless-stopped --name traffmonetizer-$(hostname) traffmonetizer/cli_v2 start accept --token SLJuGVmels0skr0k1Ydd+OtUimqd8Dy8SMdpZSu6vX8= --device-name Ubuntu$(hostname)
    if [ $? -eq 0 ]; then
        echo "TraffMonetizer container started successfully."
    else
        echo "Failed to start TraffMonetizer container. Check logs with 'docker logs traffmonetizer-$(hostname)'."
        exit 1
    fi
else
    echo "Failed to pull traffmonetizer/cli_v2 image. Check network or Docker Hub access."
    exit 1
fi

echo "All services (Repocket, Pawns.app, TraffMonetizer) installed. Check status with 'docker ps'."
