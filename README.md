# 08-Jenkins
CICD:

CI - continuous integration - Jenkins

CI is the way of integrating the code from source (multiple developers) and create artifact (probably creating build file).
In between source and creating artifact, we need to install dependencies, run unit test cases, code scans, etc. Instead of doing these manually, we can automate using CI process.
We take one server and configure these manual steps and it is jenkins server.

Jenkins is a plane webserver. When we install plugins (like git, nexus, sonar, aws, npm, nodejs etc) it can connect with other tools. In jenkins everything is a plugin.
So jenkins is popular CI server, it can connect with anything, if there is a plugin.

Similar to jenkins we have Giuhub actions, Gitlab CI, bitbucket actions, circle CI etc. Whatever the things we need to do in between source and artifcat (i.e. install dependencies, run unit test cases code scans, etc) can be placed in any CI. The purpose will be same.

The disadvantage of using github actions is , our code should be in github repos only. But Jenkins works, even if our code is in any repository.

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
Jenkins home path is /var/lib/jenkins --> JENKINS_HOME. This is default path

jenkins runs on port 8080. We can open the url "<ec2-publicIP>:8080" and get the password from the location shown. Then click on install suggested plugins, create an admin user as its shown, then jenkins is ready.

Now in jenkins we call everything as job. When it is triggered, we call it as build. 

To create pipeline job - jenkins dashboard -> new item -> select pipeline type -> ok -> here in pipeline definition, give the pipeline from SCM (i.e. from github) 

So we can store pipeline scripts in github and refer them in jenkins console as above. 

Pipeline means, multple stages. onestage output will be input to another stage.

Filename in jenkins should be Jenkinsfile

We can install different plugins in console. Dashboard -> manage jenkins -> plugins -> available plugins (eg: search for stage view plugin and add)

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

Master- agent(slave) architecture:
Usually in projects, we have one server for jenkins which will be used by different teams/modules etc. So lot of jobs/pipelines can run at a time , so server needs to handle heavy loads. So for this purpose, we have master agent architecture in jenkins. (agents are also ec2 instances). Master gets the load and passes to the agent mentioned in the pipe line. 
Another advatage of master-agent is , some pipelines may need different java versions like java7, java17 etc. So its not possible to maintain different java versions in one server. We can maintain java7 in one agent, java17 in another agent. So the pieplines can run in the corresponding agents. Even we can maintain one agent for java, one agent for node-js, one agent for python etc.

All the setup done in the above (yum install commands etc) is for master.

Steps for createing agent:
1. create an ec2 with t3.micro
2. install java, as jenkins works on java
```
sudo yum install java-17-openjdk -y
```

How to make agent connects to master?
1. login to jenkins console of master-> manager jenkins -> nodes (here builtin-node is master) -> +New Node (give node name as some name say AGENT-1)
2. number of executions -> at a time howmany jobs can be run. Based on server configuration we can choose this number.
3. give root directory of agent - this is where all jenkins jobs related info is saved.
4. Label - give label as any name say AGENT-1. Pipelines matching with this label will run in this agent.
5. Launch method -> launch via ssh -> host (private-ip) , Then add credentials with username/password or private key etc.
6. save

How to disconnect agent to master?
1. Jenkins console -> dash board -> manage jenkins -> nodes -> agent-1 -> disconnect

then click on agent node and click on log and see, master is trying to connect to agent and connection is successful.

Once the build is completed, then all its info is stored in the path given in the path given in step 4. Its stored in master node. We do not need this build info once the job is completed. So 1000's of jobs can run and we dont need them once their job is completed. So we have an option to delete once teh build id done for a job/pipeline (deleteDir()). https://www.jenkins.io/doc/pipeline/steps/workflow-basic-steps/

Jenkins follow Groovy syntax which is similar to java

disableConcurrentBuilds() - If we run a pipeline at a time by 2 persons, then its makes queue for second one. It will allow one build at a time.

disableConcurrentBuilds(abortPrevious: true) - to abort the running one and start the new build.

Parameters: When we add parameters in pipeline, then we need to build 2 times, so that jenkins considers the params in 2nd build. 1st build will fail.

triggers: when developer pushes code to githib, then it should automatically triggers the pipeline. We call them as webhooks.

webhooks: webhook can be configured from github.  
https://medium.com/@sangeetv09/how-to-configure-webhook-in-github-and-jenkins-for-automatic-trigger-with-cicd-pipeline-34133e9de0ea

https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project

After we configure webhook in github, we need to another configuration in jenkins pipeline as below in jenkins dashboard -> pipeline name -> configuration -> Build triggers

![image](https://github.com/user-attachments/assets/7b795229-ab18-4dc2-b2aa-32c8fa080108)

Here we can use cron jobs also, trigger at a particular time periodically also.

poll SCM means, we can configure like to check every one hour, if any changes occur in github , then trigger the build.

webhooks is popular

Build after other projects build is also popular and used in upstream/downstream 


Backend example: Versions are important now. Version info exists in package.json. We need to read the version info and add to docker image.

To read the version from json file, we need to install its corresponding plugin. It is "pipeline utility steps" plugin. https://www.jenkins.io/doc/pipeline/steps/pipeline-utility-steps/

Also we need to install nodejs in AGENT-1 server. Similarly we need to build docker image, so docker also needs to be installed in AGENT-1 server. (All these can be installed in a server and create an AMI)

After installing docker, its better to disconnect and connect back agent with master.

Credentials storage in Jenkins console:

When we are creating terraform infra using jenkins pipeline, then we need to do aws configure, which needs credentials/tocken. Which can be stored in Jenkins console in the path

Dashboard -> manage jenkins -> credentials -> system -> global credentials -> choose AWS credentials kind , then give some ID name and give aws key id and secret access key.

Also we need aws credentials plugin to be installed in jenkins console.

Then we can refer this ID in the jenkins pipeline as and when needed.

upstream and downstream: where there are dependencies between multiple jobs, we can trigger another pipeline when one pipeline is success.








