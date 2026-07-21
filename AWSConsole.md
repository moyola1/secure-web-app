<h1 align="left">Introduction</h1>

AWS concepts are easier to understand and retain when learned through practical, real-world applications instead of standalone theoretical lessons.
In this practical project, I’ll create a secure, real-world AWS infrastructure from scratch using core services like IAM, VPC, EC2, and CloudWatch.  Rather than simply deploying resources, the goal is to learn how each component integrates and contributes to a modern cloud-native environment.
By the end of this project, I’ll have a better understanding:

<ul>
<li>AWS Regions & Availability Zone</li>
<li>IAM (Identity and Access Management)</li>
    <ul>
        <li>Controls access and permission</li>
    </ul>
<li>VPC (Virtual Private Cloud)</li>
    <ul>
        <li>Provides an isolation network environment</li>
    </ul>
<li>Subnets (Public & Private)</li>
<li>Internet Gateway & Route Tables</li>
<li>Security Groups</li>
<li>EC2 Instance deployment</li>
<li>Basic web hosting using Apache</li>
<li>CloudWatch logging & monitoring</li>
</ul>

<h2 align="left">Architecture summary</h2>

Users &rarr; Internet &rarr; Internet Gateway &rarr; Public Subnet
EC2 Instance (Apache Web Server) &rarr; CloudWatch Logs (Monitoring)

<p align="left">
<h3 align="left">Architecture Diagram CloudWatch

![Architecture Diagram][Picture1]

<h2 align="left">Prerequisite</h2>
<h3>Step 1: Create IAM Users, Policy and Roles</h3>
Create an “Admin” user and apply best practices, Enable MFA, use the least privilege principle, and avoid using the root user for daily work

![Adminuser][Picture2]

Create a Custom Policy & Role for CloudWatch for the EC2 instance.

Select a service &rarr; CloudWatch Logs add CreateLogGroup, CreateLogStream, PutLogEvents, DescribeLogGroups
Additional permissions
Service &rarr; EC2 add DescribeTags

![CloudWatchLogsPolicy][Picture3]

![CloudWatchLogsPolicy-1][Picture3-1]

Create CloudWatch Role for the EC2 instance.

![CloudWatchLogsRole][Picture3-2]



[Picture1]: img/Picture1.png
[Picture2]: img/Picture2.png
[Picture3]: img/Picture3.png
[Picture3-1]: img/Picture3-1.png
[Picture3-2]: img/Picture3-2.png