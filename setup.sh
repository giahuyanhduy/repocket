#!/bin/bash
# Stop and remove all existing Repocket containers
docker stop $(docker ps -q --filter ancestor=repocket/repocket) 2>/dev/null || true
docker rm $(docker ps -a -q --filter ancestor=repocket/repocket) 2>/dev/null || true

# Pull and run new Repocket container
docker pull repocket/repocket
docker run -d --restart=unless-stopped repocket/repocket -email giahuyanhduy@gmail.com -api-key 858d4d30-6080-4cd0-8949-8d3ca06dcbb5
