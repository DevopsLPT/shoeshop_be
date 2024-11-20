#!/bin/bash

# Set variables
SONARQUBE_VERSION="latest"  # Change this to a specific version if needed
SONARQUBE_IMAGE="sonarqube:$SONARQUBE_VERSION"
SONARQUBE_CONTAINER_NAME="sonarqube"
SONARQUBE_PORT="9000"  # Default SonarQube port

# Update package index
echo "Updating package index..."
sudo apt-get update -y

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt install docker-ce -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker -v
  docker-compose -v
else
  echo "Docker is already installed."
fi

# Create a directory for SonarQube
echo "Creating directory for SonarQube..."
mkdir -p ./sonarqube/data ./sonarqube/extensions ./sonarqube/logs ./sonarqube/temp

# Create a Docker Compose file
echo "Creating docker-compose.yml..."
cat <<EOF > ./sonarqube/docker-compose.yml
version: '3.7'

services:
  sonarqube:
    image: $SONARQUBE_IMAGE
    container_name: $SONARQUBE_CONTAINER_NAME
    ports:
      - "$SONARQUBE_PORT:9000"
    volumes:
      - ./data:/opt/sonarqube/data
      - ./logs:/opt/sonarqube/logs
      - ./extensions:/opt/sonarqube/extensions
      - ./temp:/opt/sonarqube/temp
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonarqube
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    depends_on:
      - db
    user: "9000"

  db:
    image: postgres:latest
    container_name: sonarqube_db
    restart: always
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonarqube
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
EOF

# change user for sonarqube
sudo chown -R 9000:9000 ./sonarqube

# Start SonarQube using Docker Compose
echo ""
echo ""
echo "To start SonarQube runs follows commands:"
echo "cd ./sonarqube"
echo "docker-compose up -d"
echo "Access it at: http://0.0.0.0:$SONARQUBE_PORT"

