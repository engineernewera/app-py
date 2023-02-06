#!/bin/bash

# check the current Linux version
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VERSION=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VERSION=$(cat /etc/debian_version)
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VERSION=$(uname -r)
fi

case $OS in
    "Ubuntu")
        # add Java repository
        sudo add-apt-repository -y ppa:openjdk-r/ppa
        # update package list and install Java
        sudo apt-get update
        sudo apt-get install -y openjdk-8-jdk
        ;;
    "Debian")
        # update package list and install Java
        sudo apt-get update
        sudo apt-get install -y openjdk-8-jdk
        ;;
    "CentOS")
        # install Java
        sudo yum install -y java-1.8.0-openjdk-devel
        ;;
    "Fedora")
        # install Java
        sudo yum install -y java-1.8.0-openjdk-devel
        ;;
    *)
        echo "Error: Unsupported Linux version"
        exit 1
        ;;
esac

# install Jenkins from the correct repository
case $OS in
    "Ubuntu")
        # add Jenkins repository
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
        echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
        # update package list and install Jenkins
        sudo apt-get update
        sudo apt-get install jenkins
        ;;
    "Debian")
        # add Jenkins repository
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
        echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
        # update package list and install Jenkins
        sudo apt-get update
        sudo apt-get install jenkins
        ;;
    "CentOS")
        # add Jenkins repository
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        # install Jenkins
        sudo yum install jenkins
        ;;
    "Fedora")
        # add Jenkins repository
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        # install Jenkins
        sudo yum install jenkins
        ;;
    *)
        echo "Error: Unsupported Linux version"
        exit 1
        ;;
esac

pipeline { 
    environment{ 
    registry = 'ibadu/python-application-docker-image-sample'
    registryCredential = 'DOCKER-HUB-ACCESS-TOKEN' 
    } 
    agent any 
    triggers { 
        pollSCM('* * * * *') 
    } 
    stages { 
        stage('Cloning our github repository') { 
            steps { 
                git credentialsId: 'GIT-ACCESS-TOKEN', url: 'https://github.com/engineernewera/app-py.git', branch: 'main' 
            } 
        } 
        stage('Build docker image') { 

            steps{ 

                sh 'docker build -t app-py-image .'   
    
             } 
        
        } 
        stage('Tag the docker image') {
            steps{
                sh 'docker tag app-py-image:latest ibadu/python-application-docker-image-sample:$BUILD_NUMBER' 
                sh 'docker tag app-py-image:latest ibadu/python-application-docker-image-sample:latest ' 
            }
        }
        stage('Push image to Docker Repository') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER-HUB-ACCESS-TOKEN',passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')] ){
                    sh "echo $DOCKER_HUB_PASSWORD  | docker login -u $DOCKER_HUB_USERNAME  --password-stdin"
                    sh 'docker push $registry:$BUILD_NUMBER'
                    sh 'docker push $registry:latest'
                }
            } 
        }
    }
}
