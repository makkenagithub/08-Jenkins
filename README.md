# 08-Jenkins
CICD:

CI - continuous integration - Jenkins

CI is the way of integrating the code from source (multiple developers) and create artifact (probably creating build file).
In between source and creating artifact, we need to install dependencies, run unit test cases, code scans, etc. Instead of doing these manually, we can automate using CI process.
We take one server and configure these manual steps and it is jenkins server.

Jenkins is a plane webserver. When we install plugins (like git, nexus, sonar, aws, npm, nodejs etc) it can connect with other tools. In jenkins everything is a plugin.
So jenkins is popular CI server, it can connect with anything, if there is a plugin.

Similar to jenkins we have Giuhub actions, Gitlab CI, bitbucket actions, circle CI etc. Whatever the things we need to do in between source and artifcat (i.e. install dependencies, run unit test cases code scans, etc) can be placed in any CI. The purpose will be same.

The disadvantage of using github actions is , our code should be in github repos only. But Jenkins works, even if our code is any repository.

Jenkins installation in Linux: https://www.jenkins.io/doc/book/installing/linux/
 Create an EC2 with t3.small and run below commands

Jenkins is developed on java, so java also need to be installed.
```
sudo curl -o /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
# Add required dependencies for the jenkins package
sudo yum install fontconfig java-21-openjdk
sudo yum install jenkins
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
```
jenkins runs on port 8080. We can open the url "<ec2-publicIP>:8080" and get the password from the location shown. Then click on install suggested plugins, create an admin user as its shown, then jenkins is ready.

Now in jenkins we call everything as job. When it is triggered, we call it as build. 

To create pipeline job - jenkins dashboard -> new item -> select pipeline type -> ok -> here in pipeline definition, give the pipeline from SCM (i.e. from github) 

So we can store pipeline scripts in github and refer them in jenkins console as above. 

Pipeline means, multple stages. onestage output will be input to another stage.

Filename in jenkins should be Jenkinsfile

Pipe line syntax: https://www.jenkins.io/doc/book/pipeline/
https://www.jenkins.io/doc/book/pipeline/syntax/
```
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                //
            }
        }
        stage('Test') {
            steps {
                //
            }
        }
        stage('Deploy') {
            steps {
                //
            }
        }
    }
}
```








