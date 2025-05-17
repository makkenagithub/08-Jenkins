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
Assume job2 us dependent on job1. Means Job2 runs after job1 completes. So job1 is upstream for job2.  Job2 is downstream to job1


Sequential and parallel stages: By default stages in jenkins are sequential. One stage runs after the previous stage completes.

If one stage is independent of other stage, then we can run parallel satges.  Eg:
```
parallel {
   stage('In Parallel 1') {
       steps {
           echo "In Parallel 1"
       }
   }
   stage('In Parallel 2') {
       steps {
           echo "In Parallel 2"
       }
   }
}

```
More computational power VM is needed to run parallel jobs.


What are the jenkins agents we are using?

VMs - are permanent agents. The disadvantage is , we need to maintain them, we need to maintain multiple agents for multiple projects/applications (nodejs, java, python etc)

We can use temporary/ephemeral agents also (docker containers/k8s pods).

###### Kubernetes (k8s) restricts containers from binding to ports below 1024 due to security reasons, as these ports are considered privileged. They are system ports. As the pods run on non-root user, these ports are not allowed by k8s.

sed command: (stream editor)

It can be used to update the image version in helm values.yaml file, while running the jenkins file deployment. sed command used to update the values temporarily during jenkins deployment time.
To insert the values in place holder file, perminantly we can use "sed -i" command

```
sed -i  -> to inser perminantly
sed    -> to insert temporaruly during jenkins deployment time
sed "1 a "   -> to append after 1 line of the file
sed "1 i "   -> to inster in 1st ile of file
sed "s/local/LOCAL/g"  <file name>    -> to replace local with LOCAL in the given file temporarily
sed -i "s/local/LOCAL/g"  <file name>    -> to replace local with LOCAL in the given file permanantly
```


Devops steps:
1. Initially create infra with terraform.
2. keep ready the docker build file, k8s helm manifest files, jenkins pipelines ready with github-webhook
3. Then when the developer push the code to github, then jenkins pipeline will be triggered with github-webhook, which internally build the docker build, then push the image to ecr, Then helm charts will be run and which fetch the image from ecr and then deployed to k8s pods.

Devsecops: means, in addition to devops (as mentioned above), we need to enable the scanning in devsecops.

Scanning: (shift left) means, shifting the security scanning and testing in dev before pushing code to main branch. So when developers push code to feature branches . we should scan and test. 

Types of scan:
1. static source code analysis(checks code is written properly or not - means, app response is proper or not, means performance ) - > SonarQube can be used
2. static application security testing (checks any security issues in application code) - > SonarQube/github can be used
3. dynamic application security testing (means , when the application is placed to public, how the public can attack the application is dynamic app security tetsing.) - Veracode can be used
4. open source library scan - NexusIQ(paid service)/github(free) can be used
5. image scanning. - ECR scanning. (we are pusing image to ecr, so we have option to scan the image in ECR itself)
6. dependencies scan - blackduck, nexus scan, dependabot etc

We run the scans and provie the reports. If any issues comes in scanning, then developers need to fix them.

unit testing should be done by developers.

functional testing should be done by testers.

SRE - site reliability engineers take care of sonarqube installation upgrades etc

Sonarqube : port is 9000. We can create an ec2 with AMI of sonarqube available in markcet place. Then need to setup few things in sonarqube console. 
Console can be opened with http://<public-ip-of-sonarqube-ex2>:9000

userid/password for console is admin/admin or admin/instance-id

Sonarqube is developed using JAVA

Sonarqube can be used for 2 purposes
1. static source code analysis
2. static application security testing

In sonarqueue also we have agent master kind of thing. In jenkins we have sonar scanner agent (we install it in jenkins), which scans the code given in the jenkins pipeline , it scans/analyses that code and sends the result to sonarqube server as created above for console. Sonar server analyses those results and gives the information to jenkins.
1. sonar scanner scans/analyse the code
2. sonar server configuration should be there in sonar scanner (like sonar server url, userid/pwd etc)
3. sonar scanner reads the configuration upload the result to sonar server.

1. Install sonarqube scanner plugin in jenkins console.
2. Then Jenkins dashboard -> manage -> tools -> Add sonarqube scanner -> give name (sonar-6.0) -> isnatll from mavens and choose version 6.0 (even we can click on add scanner button below and add multiple scanners with different versions)-> apply and save
3. This completes the sonarqube scanner installation in jenkins.

Give the sonarqube server inofrmation in jenkins
1. jenkins dashboard -. manage -> system -> sonarqube servers -> add sonarqube -> give name (sonar-6.0), give sonarqube server url (http://<sonarqubeserver-privateIP>:9000) -> add authentication token (get the token from sonarqube console -> my account -> security -> generate tocken -> choose global auth token ) -> + add -> choose secret text in kind filed and give the token in secret field, -> apply and save.

https://www.geeksforgeeks.org/how-to-integrate-sonarqube-with-jenkins/

In the above we have given sonar-6.0 as name and we have choosen 6.0 version. Some application may need to use sonarqube scanner version as 5 or 4 etc. We can add different scanners with different versions and choose whatver is required for scanning a particular application.

we give project details in sonar-project.properties file seperately in real time. We get to know about all fileds in properties file from documentation only.
https://docs.sonarsource.com/sonarqube-server/9.9/analyzing-source-code/scanners/sonarscanner/
https://docs.sonarsource.com/sonarqube-server/9.9/analyzing-source-code/analysis-parameters/

Once we run the jenkins pipeline with sonar scanner, after successful run, the scanning report will be available in sonar server. 

We can create quality gate in sonarqube server console. Sonarserver console -> quality gate -> create . 
We can add some conditions such as code coverage percentage, duplicates percentage etc. If these conditions are passed then quality gate is opened. 
We add conditions on new code and overall code also. (overall code = existing code + newly commited code. And new code = newly commited/added code)

For interview purpose, we need to mention below if they ask quality gates.
In quality gates we add conditions for code quality like issues >0, bugs>0, security rating - worse than A (ratings are A,B,C,D. A is good, D is worst), code coverage <80%, code smells >0 (means guessing the code), vulnerabilities >0  etc on both overall code and new code. If any of these conditions are met, code quality fails and the failed report can be seen by developers and improve their code.

We can add as many quality gate as we can. We can use different quality gates for different projects. We can make a quality gate default for every project also.

As devops engineer, we need fail/abort the build in jenkins pipeline if the quality gate fails. If quality gate passes, the we need to pass the build and then deploy. For this we add following stage in jenkins pipe line.
```
stage('SQuality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```
Aditionally we have to give jenkins info to sonarqube i.e. webhook configuration in sonarqube server console. 
Sonarqube console -> Administration -> configuration -> webhooks -> create -> give jenkins url htto://<jenkinsIp>:8080/sonarqube-webhook/ (no need of secret)-> create 

Until now this is statis application security testing. Nect dynamic application security testing.

dynamic application security testing: Our url will be given to some third party. They will do attacks on our website url and provide the results. This testing usually performed on non-prod url. This is testing wont be doen regularly. Its done once in a while.
We have a popular tool veracode for it. Its costly tool. Freetrail is only available for business emails.

Dependencies scan:
We are downloading dependencies for nodejs from package.json. Similarly java codes download some other dependencies. So we need to scan these dependencies also.
We have nexus scan, black duck , but they are enterprose editions. Dependabot from github also there.

We can use dependency scan from github. Goto our repository having backend/frontend code -> security -> dependabot alerts -> enable

It shows the issues with priority as critical, high, moderate, low.


CI-CD:
Until now in jenkins pipeline we wrote both CI and CD. Pipeline deploys the image to k8s pods through helm. But we need to seperate CI and CD in real time.
CI triggers CD.
Image is our output. We get image from CI.

1. Dev - We use the image obtained from CI and then we use different config like values-dev.yaml file
2. QA/UAT/PROD - same image used, but different confid like values-prod.yaml.

So CI will be done only for DEV env. But in QA/UST/PROD we do not do CI. Only deployment (CD) is done. This is called shared library. Eg:  Different teams from backend can use same pipeline

In real time CI and CD are separated. We can use same image and CD job to deploy application to multiple environments. Its build once and run anywhere. 

Developers can do code commits multiple times in a day. there can be 100's of commits. But It does not mean to deploy the jenkins pipeline for every commit. We have an option to choose to deploy or not. We can use booleanParam. May be we can use choice also.

CD directory will be having helm and a jenkins file deploy.

Multi branch pipeline: every developer has his own branch (his feature brabch). So a pipeline should be there for every feature branch to support their development.

Jenkins shared library: is a pipeline as function. It takes input and run pipeline. Its CENTRAL PIPELINE. There can be 50 nodejs services/codes/projects. All these projects can call this shared pipeline at a time. No need to maintain different pipelines for different projects. 

In shared libraries, we create a groovey file eg: nodeJSEKSpipeline.groovy file. In which we define a function named call{}. We can call this shared library function from the Jenkinsfile in CI. So like this multilple projects can use the shared library at a time. 

When we mention shared library name (nodeJSEKSpipeline(input) ) in Jenkciks CI file, by default it calls call() function in groovey file of shared lib. If we define any other explicit function , then we need to call with nodeJSEKSpipeline.FUNCTION_NAME(input)

These are central pipelines. In certain projects there can be central devops engineers. They write these central pipelines (also Ansible roles, Terraform modules) and project specific devops engineers may use the shared lib central pipelines.

When we are writing central pipelines, we need think on
1. what is programming language
2. what is build tool
3. what is deployment platform

When a new project comes , then we have to plan below things to onboard the project.
1. create folders in jenkins
2. Sonarqube
3. k8s namespace
4. create ECR repo
5. veracode target
6. enable github dependabot
7. docker file
8. helm charts

To refer to shared library in jenkins 

jenkins dsahboard -> manage jenkins -> system -> global trusted pipeline libraries -> add -> name should what we have given in (@Library('jenkins-shared-lib') _ in Jenkinsfile) -> default branch - main -> tick load implicitly -> git repository should be https://github.com/makkenagithub/08-Jenkins-shared-library.git (this is where central pipelines exists (.groovy files)) -> apply and save

Now we have to create a backend pipeline in jenkins to refer to the multi branch pipeline.
Jenkins dashboard -> create pipe line -> choose multi branch pipeline -> give the git repo of the CI (09-backend-ci-jenkins-shared-lib) -> apply and save

After creating this multi branch pipeline, If there are n numner of feature branches in git , those many pipelines are automatically created. If new feature branch added, then new pipeline automatically created.










