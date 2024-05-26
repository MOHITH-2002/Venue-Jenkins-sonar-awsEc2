# Venue Web Application

This repository contains the Venue web application, which is built using React and Java. The project is configured to use Git for version control, Jenkins for continuous integration (CI), SonarQube for code quality analysis, and Docker for containerization. The deployment is set up on an AWS EC2 instance running Ubuntu 22.04.
![Screenshot](https://res.cloudinary.com/dangnbbrc/image/upload/v1716746913/Screenshot_2024-05-26_233503_pajciw.png)

## Prerequisites
- AWS EC2 instance (Ubuntu 22.04)
- Git
- Jenkins
- SonarQube
- Docker
- Java
- Node.js

## Getting Started

### 1. Setting Up the EC2 Instance
Launch an EC2 instance with Ubuntu 22.04.  
SSH into the instance:
```bash
ssh -i "your-key.pem" ubuntu@your-ec2-instance-public-ip
```
### 2. Install Git
```bash
sudo apt update
sudo apt install git -y
```
### 3. Clone the Repository
```bash
git clone https://github.com/MOHITH-2002/Venue-Jenkins-sonar-awsEc2.git
cd Venue-Jenkins-sonar-awsEc2
```
### 4. Initialize Git and Push Initial Commit
```bash
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/MOHITH-2002/Venue-Jenkins-sonar-awsEc2.git
git push -u origin main
```
### 5. Install Docker
```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```
### 6. Install Jenkins
```bash
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
```
### 7. Install SonarQube
```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.1.44547.zip
unzip sonarqube-8.9.1.44547.zip
sudo mv sonarqube-8.9.1.44547 /opt/sonarqube
sudo adduser --system --no-create-home --group --disabled-login sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube
sudo vim /etc/systemd/system/sonarqube.service


```
Add the following to /etc/systemd/system/sonarqube.service:
```bash
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
LimitNOFILE=65536
LimitNPROC=4096
Restart=always

[Install]
WantedBy=multi-user.target



```
```bash
sudo systemctl start sonarqube
sudo systemctl enable sonarqube


```
### 8. Configure Jenkins
- Access Jenkins by navigating to `http://your-ec2-instance-public-ip:8080`.
- Unlock Jenkins using the password from `/var/lib/jenkins/secrets/initialAdminPassword`.
- Install suggested plugins.
- Create an admin user.
- Configure Jenkins by adding necessary plugins for Git, Docker, and SonarQube.
### 9. Create Jenkins Pipeline
```bash
pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        SONARQUBE_CREDENTIALS = credentials('sonarqube-token')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/MOHITH-2002/Venue-Jenkins-sonar-awsEc2.git'
            }
        }
        stage('Build with Maven') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("your-dockerhub-username/venue-webapp:${env.BUILD_ID}")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'DOCKERHUB_CREDENTIALS') {
                        docker.image("your-dockerhub-username/venue-webapp:${env.BUILD_ID}").push()
                    }
                }
            }
        }
    }
}

```
### 10. Running the Application
Run the Docker container on your EC2 instance:

```bash
docker run -d -p 80:80 your-dockerhub-username/venue-webapp:latest
```
## Conclusion

This setup provides a robust CI pipeline using Jenkins, with code quality checks through SonarQube and containerization using Docker, all hosted on an AWS EC2 instance.
