#!/bin/bash

# Update the package repository and install necessary dependencies
sudo yum update -y
sudo yum install -y wget unzip

# Install Amazon Corretto 17 (Java 17)
sudo yum install -y java-17-amazon-corretto-devel

# Install Maven 3.9.9
LATEST_MAVEN_VERSION=3.9.9
wget https://dlcdn.apache.org/maven/maven-3/${LATEST_MAVEN_VERSION}/binaries/apache-maven-${LATEST_MAVEN_VERSION}-bin.zip
unzip -o apache-maven-${LATEST_MAVEN_VERSION}-bin.zip -d /opt
sudo ln -sfn /opt/apache-maven-${LATEST_MAVEN_VERSION} /opt/maven

# Set up Maven environment variables globally
echo 'export M2_HOME=/opt/maven' | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh

# Add environment variables for root user
echo 'export M2_HOME=/opt/maven' | sudo tee -a /root/.bashrc
echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /root/.bashrc

# Source the profile script to load the new environment variables
source /etc/profile.d/maven.sh

# Verify Maven installation
echo "Verifying Maven installation..."
/opt/maven/bin/mvn -version

# Download and install SonarQube 10.5.1.90531
SONARQUBE_VERSION=10.7.0.96327
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
if [ $? -ne 0 ]; then
    echo "Failed to download SonarQube. Exiting."
    exit 1
fi

unzip -o sonarqube-${SONARQUBE_VERSION}.zip -d /opt
sudo mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube

# Ensure the binaries have executable permissions
sudo chmod +x /opt/maven/bin/mvn
sudo chmod +x /opt/sonarqube/bin/linux-x86-64/sonar.sh

# Create sonarqube group and user if not exists
if ! getent group ddsonar > /dev/null; then
    sudo groupadd ddsonar
fi

if ! id -u ddsonar > /dev/null 2>&1; then
    sudo useradd -g ddsonar ddsonar
fi

sudo chown -R ddsonar:ddsonar /opt/sonarqube

# Install and use PostgreSQL
# Update the system
sudo yum update -y

# Install PostgreSQL repository
sudo amazon-linux-extras enable postgresql13

# Install PostgreSQL
sudo yum install -y postgresql-server postgresql-devel

# Initialize the PostgreSQL database
sudo postgresql-setup initdb

# Enable and start PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Set PostgreSQL to start on boot
sudo systemctl enable postgresql

# Verify PostgreSQL service status
sudo systemctl status postgresql

echo "PostgreSQL installation and setup completed."

#Create a database user named ddsonar.
sudo -i -u postgres
createuser ddsonar
psql
ALTER USER ddsonar WITH ENCRYPTED password ’Team@123;
CREATE DATABASE ddsonarqube OWNER ddsonar;
GRANT ALL PRIVILEGES ON DATABASE ddsonarqube to ddsonar;
\q
Exit

# Configure SonarQube to use PostgreSQL
sudo bash -c "cat <<EOF > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=ddsonar
sonar.jdbc.password=Team@123
sonar.jdbc.url=jdbc:postgresql://localhost:5432/ddsonarqube
EOF"

# Set up SonarQube as a service
echo -e "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=ddsonar
Group=ddsonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonar.service

# Reload systemd and start SonarQube service
sudo systemctl daemon-reload
sudo systemctl enable sonar.service
sudo systemctl start sonar.service

# Check the status of the SonarQube service
sudo systemctl status sonar.service


# Update system packages
sudo yum update -y

# Install EPEL repository for additional packages
sudo amazon-linux-extras install epel -y

# Install NGINX
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y

# Start and enable NGINX to start on boot
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Certbot and NGINX plugin for Let's Encrypt
sudo amazon-linux-extras install epel -y
sudo yum install certbot python3-certbot-nginx -y


# Set up NGINX as a reverse proxy for SonarQube
sudo bash -c 'cat > /etc/nginx/conf.d/sonarqube.conf <<EOF
server {
    listen 80;
    server_name sonarqube.dominionsystem.org;

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Test NGINX configuration
sudo nginx -t

# Reload NGINX to apply configuration
sudo systemctl reload nginx

# Obtain SSL certificate from Let's Encrypt
sudo certbot --nginx -d sonarqube.dominionsystem.org --non-interactive --agree-tos -m fusisoft@gmail.com

# Set up automatic certificate renewal
sudo crontab -l | { cat; echo "0 0 * * * /usr/bin/certbot renew --quiet"; } | sudo crontab -

# Reload NGINX to apply SSL configuration
sudo systemctl reload nginx

echo "NGINX proxy and Let's Encrypt SSL certificate installed for sonarqube.dominionsystem.org"

