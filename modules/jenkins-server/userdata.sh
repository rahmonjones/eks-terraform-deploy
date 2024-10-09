#!/bin/bash

# Update system packages
sudo apt update -y
sudo apt upgrade -y

# Install Java (Jenkins requires Java to run)
sudo apt install openjdk-11-jdk -y

# Add Jenkins repository key and package
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update -y
sudo apt install jenkins -y

# Start and enable Jenkins to start at boot
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install NGINX
sudo apt install nginx -y

# Start and enable NGINX to start at boot
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Certbot for Let's Encrypt SSL
sudo apt install certbot python3-certbot-nginx -y

# Open firewall for HTTP and HTTPS traffic
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw enable -y

# Set up NGINX as a reverse proxy for Jenkins
sudo bash -c 'cat > /etc/nginx/sites-available/jenkins.conf <<EOF
server {
    listen 80;
    server_name jenkins.dominionsystem.org;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Optional: Increase proxy buffer size if Jenkins responses are too large
    client_max_body_size 64m;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
}
EOF'

# Enable the Jenkins site and remove the default NGINX configuration
sudo ln -s /etc/nginx/sites-available/jenkins.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test NGINX configuration and reload
sudo nginx -t
sudo systemctl reload nginx

# Obtain SSL certificate using Certbot
sudo certbot --nginx -d jenkins.dominionsystem.org --non-interactive --agree-tos -m fusisoft@gmail.com

# Set up automatic certificate renewal
sudo crontab -l | { cat; echo "0 0 * * * /usr/bin/certbot renew --quiet"; } | sudo crontab -

# Reload NGINX to apply SSL configuration
sudo systemctl reload nginx

echo "Jenkins is now installed and accessible via https://jenkins.dominionsystem.org"


