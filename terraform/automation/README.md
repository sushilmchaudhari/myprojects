1.  [Network For Good](index.html)

<span id="title-text"> Network For Good : Setting up Terraform Project </span>
==============================================================================

Created by <span class="author"> Sushil Chaudhari</span>, last modified
on Jun 25, 2019

-   [1: Install
    Terraform](#SettingupTerraformProject-1:InstallTerraform)
    -   [1: Confirm we have the packages wget & unzip
        installed.](#SettingupTerraformProject-1:Confirmwehavethepackageswget&unzipinstalled.)
    -   [2: Download terraform
        binary](#SettingupTerraformProject-2:Downloadterraformbinary)
    -   [3: Extract the zip
        file.](#SettingupTerraformProject-3:Extractthezipfile.)
    -   [6: Confirm the
        installation](#SettingupTerraformProject-6:Confirmtheinstallation)
-   [2: Install AWS CLI](#SettingupTerraformProject-2:InstallAWSCLI)
    -   [a: Using homebrew on your
        mac:](#SettingupTerraformProject-a:Usinghomebrewonyourmac:)
        -   [1. Install awscli using
            brew](#SettingupTerraformProject-1.Installawscliusingbrew)
        -   [2. Give permissions to
            pkgconfig](#SettingupTerraformProject-2.Givepermissionstopkgconfig)
        -   [3. If you get below
            warning](#SettingupTerraformProject-3.Ifyougetbelowwarning)
        -   [4. Link your
            awscli](#SettingupTerraformProject-4.Linkyourawscli)
        -   [5. Check if it is
            working](#SettingupTerraformProject-5.Checkifitisworking)
    -   [b: Using pip on your
        mac:](#SettingupTerraformProject-b:Usingpiponyourmac:)
-   [3: Create separate AWS
    Organization](#SettingupTerraformProject-3:CreateseparateAWSOrganization)
-   [4: Create IAM User](#SettingupTerraformProject-4:CreateIAMUser)
-   [5. Configure AWS credentials using
    aws-cli](#SettingupTerraformProject-5.ConfigureAWScredentialsusingaws-cli)
-   [6. Clone Terraform scripts from Git
    Repo.](#SettingupTerraformProject-6.CloneTerraformscriptsfromGitRepo.)
-   [7. Create Environment
    folder](#SettingupTerraformProject-7.CreateEnvironmentfolder)
-   [8. Copy files from
    example](#SettingupTerraformProject-8.Copyfilesfromexample)
-   [9. Create S3 bucket for remote
    state](#SettingupTerraformProject-9.CreateS3bucketforremotestate)
-   [10. Set remote state for terraform
    project.](#SettingupTerraformProject-10.Setremotestateforterraformproject.)
-   [11: Change the database
    template](#SettingupTerraformProject-11:Changethedatabasetemplate)
-   [12: Provider
    Configuration](#SettingupTerraformProject-12:ProviderConfiguration)
-   [13: Copy SSL
    certificates.](#SettingupTerraformProject-13:CopySSLcertificates.)
-   [14: Create ssh key
    files](#SettingupTerraformProject-14:Createsshkeyfiles)
-   [15: Define
    variables](#SettingupTerraformProject-15:Definevariables)
-   [16: Run Terraform
    Commands](#SettingupTerraformProject-16:RunTerraformCommands)
    -   [1: Initialize ](#SettingupTerraformProject-1:Initialize)
    -   [2: Plan](#SettingupTerraformProject-2:Plan)
    -   [3: Apply](#SettingupTerraformProject-3:Apply)
-   [17: Copy ymls on Management
    instance](#SettingupTerraformProject-17:CopyymlsonManagementinstance)
-   [18: Copy inventory on Management
    instance](#SettingupTerraformProject-18:CopyinventoryonManagementinstance)
-   [19: Add users to SNS notification
    topic](#SettingupTerraformProject-19:AdduserstoSNSnotificationtopic)
    -   [1: Find the topic
        name](#SettingupTerraformProject-1:Findthetopicname)
    -   [2: Please follow below steps to add users to SNS
        topics.](#SettingupTerraformProject-2:PleasefollowbelowstepstoadduserstoSNStopics.)
-   [20: Setting up CloudWatch alarm for Disk
    Utilization](#SettingupTerraformProject-20:SettingupCloudWatchalarmforDiskUtilization)
    -   [Monitor Root
        Partition](#SettingupTerraformProject-MonitorRootPartition)
    -   [Monitor Data
        Partition](#SettingupTerraformProject-MonitorDataPartition)

To setup Terraform project, please follow below instructions.

1: Install Terraform
====================

### **1: **<span style="color: rgb(34,34,34);">Confirm we have the packages wget & unzip installed.</span>

<span style="color: rgb(34,34,34);"><span
style="color: rgb(34,34,34);">For Red Hat / CentOS, Run the
below:</span>  
</span>

``` syntaxhighlighter-pre
yum install wget unzip
```

For Ubuntu / Debian

``` syntaxhighlighter-pre
apt-get install wget unzip
```

For MacOS

``` syntaxhighlighter-pre
brew install wget unzip
```

### ** 2: **<span style="color: rgb(34,34,34);">Download terraform binary</span>

<span style="color: rgb(34,34,34);">First visit the terraform download
page using the
link:<a href="https://releases.hashicorp.com/terraform/0.11.14/" class="external-link">https://releases.hashicorp.com/terraform/0.11.14/</a></span>

<span style="color: rgb(34,34,34);">Checkout for your prefer OS and Arch
(32-bit / 64-bit) and Simply right click on the 32-bit / 64-bit option
and select the "Copy Link Address".</span>

<span
class="confluence-embedded-file-wrapper confluence-embedded-manual-size"><img src="https://www.slashroot.in/sites/default/files/Terraform%20Download.png" class="confluence-embedded-image confluence-external-resource confluence-content-image-border" width="427" height="150" /></span>

Open **Termial **<span style="color: rgb(34,34,34);">, enter the command
wget followed by a space and then paste the copied link there, and press
enter. This will download terraform binary in zip format directly to the
server.</span>

``` syntaxhighlighter-pre
wget <COPIED LINK>


For Eg: For MacOS


wget https://releases.hashicorp.com/terraform/0.12.1/terraform_0.12.1_darwin_amd64.zip
```

### <span style="color: rgb(34,34,34);">** 3: **<span style="color: rgb(34,34,34);">Extract the zip file.</span></span>

<span style="color: rgb(34,34,34);"><span
style="color: rgb(34,34,34);">Run below command to extract the zip file.
You get binary file named "terraform" after extraction.</span></span>

``` syntaxhighlighter-pre
unzip terraform*
```

**  
5: <span style="color: rgb(34,34,34);">Move terraform binary to
/usr/local/bin/</span>**<span
style="font-size: 16.0px;font-weight: bold;">.</span>

Move binary file from **Step 4, **to /usr/local/bin

``` syntaxhighlighter-pre
mv terraform /usr/local/bin/
```

### ** 6:**<span style="color: rgb(34,34,34);"> </span><span style="color: rgb(34,34,34);">Confirm the installation</span>

<span style="color: rgb(34,34,34);">Confirm the terraform installation
by executing the terraform command, It should show version as
"</span>Terraform v0.11.14<span style="color: rgb(34,34,34);">".</span>

``` syntaxhighlighter-pre
# terraform --version

Terraform v0.11.14
```

<span style="color: rgb(34,34,34);">2: Install AWS CLI</span>
=============================================================

a: Using homebrew on your mac:
------------------------------

### 1. Install awscli using brew

``` syntaxhighlighter-pre
$ brew install awscli
```

### 2. Give permissions to pkgconfig

``` syntaxhighlighter-pre
$ chmod 755 /usr/local/lib/pkgconfig
```

### 3. If you get below warning

``` syntaxhighlighter-pre
Warning: awscli 1.14.30 is already installed, it's just not linked.You can use `brew link awscli` to link this version.
```

### 4. Link your awscli

``` syntaxhighlighter-pre
$ brew link awscli
```

### 5. Check if it is working

``` syntaxhighlighter-pre
$aws 
usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:
aws help
aws <command> help
aws <command> <subcommand> help
```

b: Using pip on your mac:
-------------------------

Please follow instruction give in below link to install aws-cli on your
MacOS using pip.

<a href="https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#awscli-install-osx-pip" class="external-link">https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#awscli-install-osx-pip</a>

3: Create separate AWS Organization
===================================

Every environment should have separate AWS account. This is achieved by
creating multiple AWS organizations under root AWS account. Please
follow the steps provided in below link to create a organization.

<a href="https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create.html" class="external-link">https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create.html</a>

4: Create IAM User
==================

Once the Organization is created, create a IAM user with administrative
access. Follow the below steps.

**To create an IAM group and attach policies (console)**

1.  Sign in to the AWS Management Console created in **Step 3** and open
    the **IAM** console
    at <a href="https://console.aws.amazon.com/iam/" class="external-link">https://console.aws.amazon.com/iam/</a>.

2.  In the navigation pane, click **Groups** and then click **Create New
    Group**.

3.  In the **Group Name** box, type the name **Administrators** of the
    group and then click **Next Step**.

4.  In the list of **policies**, select the policy
    **AdministratorAccess** check box . Then click **Next Step**.

5.  Click **Create Group**.

**To create  IAM users (console)**

1.  Sign in to the AWS Management Console created in **Step 3** and open
    the **IAM** console
    at <a href="https://console.aws.amazon.com/iam/" class="external-link">https://console.aws.amazon.com/iam/</a>.

2.  In the navigation pane, choose **Users** and then choose **Add
    user**.

3.  Type the user name for the new user. This is the sign-in name for
    AWS.

4.  Select the below type of access this set of users will have.

    -   Select **Programmatic access** if the users require access to
        the API, AWS CLI, or Tools for Windows PowerShell. This creates
        an access key for each new user. You can view or download the
        access keys when you get to the **Final** page.

    -   Select **AWS Management Console access** if the users require
        access to the AWS Management Console. This creates a password
        for each new user.

    1.  For **Console password**, choose one of the following:

        -   **Autogenerated password**. Each user gets a randomly
            generated password that meets the account password policy in
            effect (if any). You can view or download the passwords when
            you get to the **Final**page.

        -   **Custom password**. Each user is assigned the password that
            you type in the box.

    2.  We recommend that you select **Require password reset** to
        ensure that users are forced to change their password the first
        time they sign in.

5.  Choose **Next: Permissions**.

6.  On the **Set permissions** page, specify how you want to assign
    permissions to this set of new users. Choose one of the following
    three options:

    -   **Add user to group**. Choose this option and add user to
        **Administrators** group created earlier

7.  (Optional) Skip Set
    a <a href="https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html" class="external-link">permissions boundary</a>.

8.  Choose **Next: Tags**.

9.  (Optional) Add metadata to the user by attaching tags as key-value
    pairs.

10. Choose **Next: Review** to see all of the choices you made up to
    this point. When you are ready to proceed, choose **Create user**.

11. To view the users' access keys (access key IDs and secret access
    keys), choose **Show** next to each password and access key that you
    want to see. To save the access keys, choose **Download .csv** and
    then save the file to a safe location.

5. Configure AWS credentials using aws-cli
==========================================

After creating IAM user in Step 4, create a credential profile which
will be used to run terraform script.

Below command asks for Access Key ID and Secret Access Key of the IAM
user you created in **Step 4**

``` syntaxhighlighter-pre
$ aws configure --profile <PROFILE_NAME>
AWS Access Key ID [None]: <ACCESS KEY ID OF IAM USER FROM Step 4>
AWS Secret Access Key [None]: <SECRET ACCESS KEY ID OF IAM USER FROM Step 4>
Default region name [None]: <DEFAULT REGION NAME WHERE YOU WANT TO CREATE TF RESOURCES>
Default output format [None]: <ENTER>
```

You can check the credentials in file

\~/.aws/credentials and \~/.aws/config

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

This is important step in the process of running Terraform script.

6. Clone Terraform scripts from Git Repo.
=========================================

Clone the terraform scripts from git repo.

``` syntaxhighlighter-pre
git clone <git-repo.git>
```

Change to 

``` syntaxhighlighter-pre
$ cd infrastructure/automation
automation$ ls 
certs   example modules
automation$ 
```

7. Create Environment folder
============================

As per the best practice, one should create separate folders for
separate envs like for qa, prod, test, beta etc.

So create a folder based on env name.  

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

For documentation purpose we are using environment as "**qa**". You
should use respective environment name.

  
If prod, then

``` syntaxhighlighter-pre
automation$ mkdir prod
```

If qa, then

``` syntaxhighlighter-pre
automation$ mkdir qa
```

If beta, then

``` syntaxhighlighter-pre
automation$ mkdir beta
```

<span style="color: rgb(34,34,34);">etc.</span>

  

8. Copy files from example
==========================

Copy all the files and folder available in example folder to env folder.

If prod, then

``` syntaxhighlighter-pre
automation$ cp -r example/* prod/
```

If qa, then

``` syntaxhighlighter-pre
automation$ cp -r example/* qa/
```

If beta, then

``` syntaxhighlighter-pre
automation$ cp -r example/* beta/
```

<span style="color: rgb(34,34,34);">etc.</span>

<span style="color: rgb(34,34,34);">And change  directory to specific
env. </span>

``` syntaxhighlighter-pre
automation$ cd qa
qa$ ls
alb.tf        cloudwatch.tf ec2.tf        inventory     main.tf       provider.tf   script.sh     templates

backend.tf    db.tf         iam.tf        inventory.tf  outputs.tf    redis.tf      sg.tf         variables.tf
```

9. Create S3 bucket for remote state
====================================

When working with Terraform as a team, it is always ideal to set up a
remote state as multiple people want to update the same state file. We
are going to use S3 to save remote state of  terraform.

<span
class="aui-icon aui-icon-small aui-iconfont-info confluence-information-macro-icon"></span>

What is Remote State?

Take a look at
<a href="https://www.terraform.io/docs/state/remote.html" class="external-link">https://www.terraform.io/docs/state/remote.html</a>

  

1.  Sign in to the AWS Management Console created in **Step 3**console
    at <a href="https://console.aws.amazon.com/iam/" class="external-link">https://console.aws.amazon.com/iam/</a>.

2.  Under **Storage & Content Delivery**, choose **S3** to open the
    Amazon S3 console.

3.  From the Amazon S3 console dashboard, choose **Create Bucket**.

4.  In **Create a Bucket**, type a bucket name in \<**Bucket Name\>**.

5.  In **Region**, choose **Respective Region**.

6.  Choose **Create**.

    When Amazon S3 successfully creates your bucket, the console
    displays your empty bucket in the **Buckets** pane.

7.  <span style="color: rgb(68,68,68);">Go to the **Buckets** pane, In
    the </span>**Bucket name**<span style="color: rgb(68,68,68);"> list,
    choose the Bucket name just created.</span>
8.  <span style="color: rgb(68,68,68);"><span
    style="color: rgb(68,68,68);">Choose </span>**Create folder**<span
    style="color: rgb(68,68,68);">.</span>  
    </span>
9.  <span style="color: rgb(68,68,68);"><span
    style="color: rgb(68,68,68);"><span
    style="color: rgb(68,68,68);">Type a name for the folder as
    **qa**-**terraform-states ** then choose </span>**Save**<span
    style="color: rgb(68,68,68);">. Change the environment when
    necessary.</span></span></span>

  

10. Set remote state for terraform project.
===========================================

Now you have created a S3 bucket to save terraform state remotely, add
the S3 details in below to take the effect.

Open **backend.tf** in your favorite editor, here I am using vi

``` syntaxhighlighter-pre
qa$ vi backend.tf
```

Replace the values which from earlier steps

``` syntaxhighlighter-pre
terraform {
  backend "s3" {
    bucket = "< BUCKET NAME FROM STEP 9 >"
    key    = "<FOLDER_NAME_Step_9.9>/terraform.tfstate"
    region = "< AWS REGION WHERE BUCKET IS CREATED >"
    profile = "< AWS PROFILE NAME CREATED in STEP 5>"
  }
}
```

Save and quit file.

Now Run below command to initialize remote state setup.

``` syntaxhighlighter-pre
qa$ terraform init



Initializing modules...
- module.main-alb
- module.master_db
- module.replica
- module.app-ec2
- module.worker-ec2
- module.mgt-ec2
- module.main-vpc
- module.ec-redis-jobs
- module.ec-redis-cache
- module.main-sg

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.13"
* provider.null: version = "~> 2.1"
* provider.random: version = "~> 2.1"
* provider.template: version = "~> 2.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Above command installs all the modules required to run the terraform
scripts.

11: Change the database template
================================

You will find the 3 templates for database.yml , redis.yml and
redis-jobs.yml under **templates** folder.

``` syntaxhighlighter-pre
qa$ ls templates
database.yml.tpl   redis-jobs.yml.tpl redis.yml.tpl
```

Assign the variable DB\_NAME in front of required environment database
name.

1: Open database..yml

``` syntaxhighlighter-pre
qa$ cd templates
templates$ vi database.yml
```

And assign value as per the environment. 

For prod:

``` syntaxhighlighter-pre
default: &default
  adapter: mysql2
  host: ${DB_HOST}
  port: 3306
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  encoding: utf8
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: ""

staging:
  <<: *default
  database: ""

beta:
  <<: *default
  database: ""

qa:
  <<: *default
  database: ""

production:
  <<: *default
  database: ${DB_NAME}
```

For qa:

``` syntaxhighlighter-pre
default: &default
  adapter: mysql2
  host: ${DB_HOST}
  port: 3306
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  encoding: utf8
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: ""

staging:
  <<: *default
  database: ""

beta:
  <<: *default
  database: ""

qa:
  <<: *default
  database: ${DB_NAME}

production:
  <<: *default
  database: ""
```

Save and quit.

12: Provider Configuration
==========================

Provider offers a set of named resource types, and defines for each
resource type which arguments it accepts, which attributes it exports,
and how changes to resources of that type are actually applied to remote
APIs.

We are using AWS provider to create required resources. To create
provider configuration follow the below steps.

1: Create provider.tf file.

``` syntaxhighlighter-pre
qa$ touch provider.tf
```

2: Open provider.tf 

``` syntaxhighlighter-pre
qa$ vi provider.tf
```

3: Add below contents in provider.tf

``` syntaxhighlighter-pre
provider "aws" {
  region = "${var.AWS_REGION}"
  profile = "< PROFILE NAME CREATED IN Step 5 >"
}
```

4: Save and quit.

13: Copy SSL certificates.
==========================

Terraform projects uses ssl certificates to enable https routing and
assigns it to Load Balancer. Defaults are self-signed certificates which
are available in certs/ folder.

``` syntaxhighlighter-pre
$ cd infrastructure/automation
automation$ ls 
certs   example modules
automation$ cd certs
certs$ ls
server.crt server.csr server.key
```

To use signed certificates, copy your certificate files in certs/
directory

``` syntaxhighlighter-pre
$ cd infrastructure/automation
automation$ cp < path_of_signed_crt_file > certs/server.crt
automation$ cp < path_of_signed_key_file > certs/server.key
```

14: Create ssh key files
========================

When you create an instance on AWS, ssh key files are necessary to
connect to it. You can provide ssh keys to Terraform, which will be used
in instance creation process.

Follow the below process to create ssh key files.

1: Enter the following command. This starts the key generation process.
When you execute this command, the ssh-keygen utility prompts you to
indicate where to store the key.

``` syntaxhighlighter-pre
$ ssh-keygent -t rsa
```

2: Press the `ENTER` key to accept the default location or pass key file
name.

``` syntaxhighlighter-pre
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/test/.ssh/id_rsa): qa_aws_tf_id_rsa
```

3:  The ssh-keygen utility prompts you for a passphrase. Type in a
passphrase. You can also hit the `ENTER` key to accept the default (no
passphrase). You will need to enter the passphrase a second time to
continue.

``` syntaxhighlighter-pre
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/test/.ssh/id_rsa): qa_aws_tf_id_rsa
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
```

4: After you confirm the passphrase, the system generates the key pair
and you will see output like this:

``` syntaxhighlighter-pre
Your identification has been saved in qa_aws_tf_id_rsa.
Your public key has been saved in qa_aws_tf_id_rsa.pub.
The key fingerprint is:
SHA256:QlODlvcn/lxw48HxxrAFsQ7g6lBMrD6IPFVaEqx4698 Sushil@Sushils-MacBook-Pro.local
The key's randomart image is:
+---[RSA 2048]----+

|   ... ++ .   oo |

|    o *+oo .  o..|

| . . *ooo.. ...B |

|. o o..o .o oo* +|

| o + oo S. o +.+ |

|  = . o+  .   o  |

| . .   ..  o .   |

|  .  .      o    |

|   .. E          |

+----[SHA256]-----+
```

  

15: Define variables
====================

Terraform configurations in .tf files accept values from input
variables. These variables are used in configuration using
Terraform’s interpolation syntax. 

Variable definitions are in **variables.tf** file. The variable
definitions have default values assigned to them. Each variable
definition has their own description.

For eg: variable "app\_instance\_count" in below block has default value
as "1".

``` syntaxhighlighter-pre
variable "app_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}
```

The variables which don't have default values, TF expects values to be
entered while running terraform commands like plan or apply. 

So one way is to populate variable values via files, does allow
persistence. When Terraform runs it will look for a file called
**terraform.tfvars**. We can populate this file with variable values
that will be loaded when Terraform runs.

1: Create **terraform.tfvars** file.

``` syntaxhighlighter-pre
qa$ touch terraform.tfvars
```

When Terraform runs it will automatically load the **terraform.tfvars**
file and assign any variable values in it.

2: Populate the variables which don't have default values. Below is the
list of variables which are needed to run the terraform scripts. For
more description, please refer **variables.tf** file.

Open terraform.tfvars

``` syntaxhighlighter-pre
qa$ vi terraform.tfvars
```

Below is the list of variables which should be defined before running
the terraform commands.

``` syntaxhighlighter-pre
name = ""


AWS_REGION = ""


tags = {
    Terraform = true
    Environment = ""
}

app_ami = "< APP BASE IMAGE ID>"
worker_ami = "< WORKER BASE IMAGE ID >"
mgt_ami = "<MGT BASE IMAGE ID>"

app_instance_count = 
worker_instance_count = 
mgt_instance_count = 

app_instance_type = 
worker_instance_type = 
mgt_instance_type = 

create_new_key_pair = true
ssh_key_filename = "<.pub KEY GENERATED IN Step 14>"
ssh_key_pair_name = ""


enable_nat_gateway = "true"

app_root_volume_size = 20
worker_root_volume_size = 20
mgt_root_volume_size = 20

app_data_volume_size = 20
worker_data_volume_size = 20
mgt_data_volume_size = 20



database_name = ""
database_user = ""
database_passwd = ""

master_db_identifier = ""
replica_db_identifier = ""

redis_jobs_node_count = 
redis_jobs_node_type = ""

redis_cache_node_count = 
redis_cache_node_type = ""


enable_https = 
cert_crt_file_path = "../certs/server.crt"
cert_key_file_path = "../certs/server.key"


enable_cloudwatch = 
```

  

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

For default values , please refer to variables.tf file. It has
description of all the variables. You can override the default value of
any variable, by adding in it **terraform.tfvars** file.

16: Run Terraform Commands
==========================

 Once you are through with all above steps, its time to create
infrastructure. Please follow below steps.

### 1: Initialize 

command is used to initialize a working directory containing Terraform
configuration files.

``` syntaxhighlighter-pre
qa$
terraform init
```

### 2: Plan

Run Terraform plan . The `terraform plan` command is used to create an
execution plan. Terraform performs a refresh, unless explicitly
disabled, and then determines what actions are necessary to achieve the
desired state specified in the configuration files.

This command is a convenient way to check whether the execution plan for
a set of changes matches your expectations without making any changes to
real resources or to the state.

``` syntaxhighlighter-pre
qa$ terraform plan
```

### 3: Apply

command is used to apply the changes required to reach the desired state
of the configuration, or the pre-determined set of actions generated by
a `terraform plan` execution plan.

``` syntaxhighlighter-pre
qa$ terraform apply
```

17: Copy ymls on Management instance
====================================

After infrastructure is ready, Terraform creates yml files under
inventory/ directory. These files are used in Capistrano deployment. To
make these file available to Capistrano, you have to copy ymls on
Managament instance. To copy, use below commands

1: Get the IP of Management server

Run terraform output which gives you Management IP address. 

``` syntaxhighlighter-pre
qa$ terraform output mgt_public_ip_address
54.69.23.161
```

**  
  
**2: Once you get the management server IP, use private key generated in
**Step 14** to connect using SSH. 

``` syntaxhighlighter-pre
qa$ scp -i <path-of-private-key-generated-in-step-14> inventory/*.ymls ubuntu@<management_server_ip_from_above_command>:/tmp/
```

This will copy all ymls on management server under /tmp folder.

18: Copy inventory on Management instance
=========================================

Terraform also creates inventory file which contains host-ip details of
app and worker instances. The contents looks like

``` syntaxhighlighter-pre
qa$ cat inventory/inventory 

10.0.1.79                        qa.app1.nfg.org
10.0.2.14                        qa.app2.nfg.org
10.0.1.202                       qa.app3.nfg.org
10.0.2.62                        qa.app4.nfg.org
10.0.10.52                       qa.worker1.nfg.org
10.0.11.156                      qa.worker2.nfg.org
```

Copy these contents in /etc/hosts on Management server.

1: First connect to Management server

``` syntaxhighlighter-pre
qa$ ssh -i <path-of-private-key-generated-in-step-14> ubuntu@<management-server-ip>
```

2: Open /etc/hosts and copy contents.

``` syntaxhighlighter-pre
<management-server-ip>$ sudo vi /etc/hosts


Append inventory contents 
```

3: Save and quit.

19: Add users to SNS notification topic
=======================================

Terraform does not support authorization of email ids  because the
endpoint needs to be authorized and does not generate an ARN until the
target email address has been validated. This breaks the Terraform model
and as a result are not currently supported.

So adding email ids to SNS topic for cloudwatch monitoring should be
manual.

### 1: Find the topic name

Get the topic details from below command

``` syntaxhighlighter-pre
qa$ terraform output cw_notification_group
```

### 2: Please follow below steps to add users to SNS topics.

1.  Sign in to the AWS Management Console created in **Step 3 **console
    at <a href="https://console.aws.amazon.com/" class="external-link">https://console.aws.amazon.com/</a>.

2.  On the navigation panel, choose **Subscriptions**.

3.  On the **Subscriptions** page, choose **Create subscription**.

4.  On the **Create subscription** page, do the following:

    1.  Enter the **Topic ARN** of the topic created earlier from **Step
        19.1.**

    2.  For **Protocol**, select an endpoint type, for
        example **Email**.

    3.  For **Endpoint**, enter an email address that can receive
        notifications, for example:

        ``` programlisting
        name@example.com
        ```

        Note

        After your subscription is created, you must confirm it. 

    4.  Choose **Create subscription**.

        The subscription is created and
        the ***`Subscription: 1234a567-bc89-012d-3e45-6fg7h890123i`*** page
        is displayed.

        The
        subscription's **ARN**, **Endpoint**, **Topic**, **Status** (**Pending
        confirmation** at this stage), and **Protocol** are displayed in
        the **Details** section.

5.  In your email client, check the email address that you specified and
    choose **Confirm subscription** in the email from Amazon SNS.

6.  In your web browser, a subscription confirmation with your
    subscription ID is displayed.

  

20: Setting up CloudWatch alarm for Disk Utilization
====================================================

Monitor Root Partition
----------------------

Terraform script is now creates an alarm for Root disk utilization.
Below is the configuration added in **cloudwatch.tf**.

``` syntaxhighlighter-pre
resource "aws_cloudwatch_metric_alarm" "Disk-utilization-root" {
  count               = "${var.app_instance_count + var.worker_instance_count}"
  alarm_name          = "Disk-utilization-root-${element(concat(module.app-ec2.instance_ids_cloudwatch,module.worker-ec2.instance_ids_cloudwatch), count.index)}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ec2 Disk utilization"
  alarm_actions       = ["${aws_sns_topic.alarm.arn}"]

  dimensions {
    path = "/"
    device = "xvda1"
    fstype = "ext4"
    InstanceId = "${element(concat(module.app-ec2.instance_ids_cloudwatch,module.worker-ec2.instance_ids_cloudwatch), count.index)}"
  }
}
```

Monitor Data Partition
----------------------

There is a provision to create an alarm to monitor  data partition.
There are 2 case.

**1: If data partition is created by Terraform script by enabling
"required\_data\_partition = true". Terraform creates an alarm as
below.**

  

``` syntaxhighlighter-pre
resource "aws_cloudwatch_metric_alarm" "Disk-utilization-data" {
  count               = "${var.enable_cloudwatch && var.required_data_partition ? var.app_instance_count + var.worker_instance_count : 0}"
  alarm_name          = "Disk-utilization-data-${element(concat(module.app-ec2.instance_ids_cloudwatch,module.worker-ec2.instance_ids_cloudwatch), count.index)}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ec2 Disk utilization"
  alarm_actions       = ["${aws_sns_topic.alarm.arn}"]

  dimensions {
    path = "/data"
    device = "xvdn"
    fstype = "ext4"
    InstanceId = "${element(concat(module.app-ec2.instance_ids_cloudwatch,module.worker-ec2.instance_ids_cloudwatch), count.index)}"
  }
}
```

**2: If data partition is created by Terraform script by enabling
"required\_data\_partition = true". Terraform creates an alarm as
below.**

If data partition is not created by Terraform , the user have to change
the few parameters which are mentioned as below.

Please change the Dimensions 

path =\> The name of the mount point/folder on which data disk is
mounted on Instance. For Eg: /data

device =\> The name of the device on linux machine. You can get the
device name using command "<span
style="color: rgb(0,0,255);">`lsblk`</span>". For Eg: If device name is
/dev/xvdn, just use xvdn.

``` syntaxhighlighter-pre
resource "aws_cloudwatch_metric_alarm" "Disk-utilization-data" {
  count               = "${var.enable_cloudwatch && var.required_data_partition ? var.app_instance_count + var.worker_instance_count : 0}"
  alarm_name          = "Disk-utilization-data-${element(concat(module.app-ec2.instance_ids_cloudwatch,module.worker-ec2.instance_ids_cloudwatch), count.index)}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ec2 Disk utilization"
  alarm_actions       = ["${aws_sns_topic.alarm.arn}"]

  dimensions {
    path = "<MOUNT POINT WHERE DISK IN MOUNTED>"
    device = "<DEVICE NAME AVAILABLE ON INSTANCE Eg: xvdn, xvdg etc>"
    fstype = "ext4"
    InstanceId = "${element(concat(module.app-ec2.instance_ids_cloudwatch,module.worker-ec2.instance_ids_cloudwatch), count.index)}"
  }
}
```
