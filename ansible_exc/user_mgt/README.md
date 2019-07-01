
SSH User Management
This manages users in the user list configuration file (list is in the file vars/lab_users.secret in the example below). It can add users, delete users, change passwords, lock/unlock user accounts, manage sudo access (per user), add ssh key(s) for ssh key based authentication.

1: Install Python3
If you don't have python3 installed, Please follow the instructions from below link with respect to the flavour of OS you are using to install python3.

https://realpython.com/installing-python/#macos-mac-os-x

2: Install Ansible
The pip command is a tool for installing and managing Python packages, such as those found in the Python Package Index. The following method works on Linux and Unix-like systems

local$ sudo pip install ansible


For more reference on Ansible installation , please refer https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

3: Validate Installation
After installing Ansible, validate the installation using below command.

local$ ansible --version
ansible 2.8.1
  config file = None
  configured module search path = ''
  ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.7.3 (default, May 10 2019, 12:08:37) [Clang 10.0.1 (clang-1001.0.46.3)]
4: Clone Ansible scripts from Git Repo
Clone the terraform scripts from git repo.

local$ git clone <git-repo.git>
Change to 

local$ cd infrastructure/user_mgt
user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         vars
user_mgt$ 
5: Setup Ansible Vault
Ansible Vault uses AES encryption to store your sensitive information. And we need Ansible Vault to encrypt our user configuration file since we don’t want to be exposing even a hashed password into source control. You will need to set it up.

1: Create a vault password file
Create a password for your Ansible Vault by creating the .vaultpass file, add the Vault password, and fix the permissions:

local@user_mgt$ echo "<your_secret_password>" > .vaultpass
local@user_mgt$ chmod 600 .vaultpass
2: Add .vaultpass to Gitignore
Make sure to update your .gitignore file so your Vault password isn’t saved to your source control. And also add the secret file we will be creating later:

local$ cd <git cloned directory>


local$ ls -a .gitignore
.gitignore


local$ echo "infrastructure/user_mgt/.vaultpass" >> .gitignore


The ansible config file is already updated to reference where the Vault file is located. You can check the ansible configuration file

infrastructure/user_mgt/ansible.cfg



6: Configure ssh for Ansible
The app/worker instances are accessible only through Management server. We need this configuration for ansible to connect to app and worker instances through Management.

1: Open ssh.cfg

local$ cd infrastructure/user_mgt
local:user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         test.yml        vars


local:user_mgt$ vi ssh.cfg
2: Edit file with necessary values

Host <MANAGEMENT INSTANCE IP>
  User ubuntu
  IdentityFile <id_rsa FILE PATH USED TO CREATE INSTANCES IN TERRAFORM SCRIPT>

Host <SPACE SEPARATED APP INSTANCE IP ADDRESSES>
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ProxyCommand ssh -W %h:%p ubuntu@<MANAGEMENT INSTANCE IP>
  IdentityFile <id_rsa FILE PATH USED TO CREATE INSTANCES IN TERRAFORM SCRIPT>

Host <SPACE SEPARATED WORKER INSTANCE IP ADDRESSES>
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ProxyCommand ssh -W %h:%p ubuntu@<MANAGEMENT INSTANCE IP>
  IdentityFile <id_rsa FILE PATH USED TO CREATE INSTANCES IN TERRAFORM SCRIPT>

3: Save and Quit

7: Setup Inventory for Ansible
1: Open inventory file

local$ cd infrastructure/user_mgt
local:user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         test.yml        vars


local:user_mgt$ vi inventory
2: Edit file with necessary values

[mgt]
<MANAGEMENT INSTANCE IP>

[app]
<APP INSTANCE IP ADDRESSES>

[worker]
<WORKER INSTANCE IP ADDRESSES>

For eg:

[mgt]
34.220.44.254

[app]
10.0.1.57
10.0.2.97
10.0.1.109
10.0.2.56

[worker]
10.0.10.51
10.0.11.54
3: Save and Quit

You can find Management, App and Worker instance Ip addresses in terraform output. Setting up Terraform Project

8: Create configuration for user
Next, add your users into a configuration file. The below is only an example, 

1: Generate User password
Ansible needs User password to be encrypted in specific format. Please follow the instruction to create encrypted password and use in configuration file.

a: Open link https://www.mkpasswd.net/index.php

b: Enter required details

Password -  Password in plain text. Password is not visible in text box. So careful while typing password. For Eg: hello123
Type          -  Select crypt - sha512
Leave Category as blank.
Click on Hash button to generate encrypted password.
c: An encrypted password is available in Hashed text box.

2: Create Configuration file
There is special command to create configuration file. Please use below command to create configuration file.

local$ cd infrastructure/user_mgt/


local$ ansible-vault create vars/lab_users.secret
The tool will launch with default editor vi. Add user configuration like below

---
users:
  - username: <USERNAME>
    password: <SHA-512 ENCRYPTED PASSWORD>
    update_password: <on_create | always>
    comment: <COMMENT>
    shell: /bin/bash
    ssh_key: "<SSH KEY OF THE USER>"
    exclusive_ssh_key: yes
    use_sudo: <yes|no>
    use_sudo_nopass: <yes|no>
    user_state: <present | absent | lock>
Save and Quit.

User Settings:
Settings	Description	Allowed Values	Required
username	User name with no spaces	
Yes
user_state	State of the user	
present - To add user

absent - To delete user

lock - To lock user

Yes
password	
Sha-512 encrypted password of the user.

If the password field is not defined, "!" is set


No
update_password	When to update password	
on_create - update password only while creating user

always - every time when script is run

No
comment	Full name and Department or description of application	
No
groups	Comma separated list of groups the user will be added to	
No
shell	path to shell. default is /bin/bash	
No
ssh_key	User's ssh key for ssh key based authentication	
No
exclusive_ssh_key	
Whether to remove all other non-specified keys from the authorized_keys file.

Default is no. Recommended not to change this

yes | no

No
sudo	Allow admin privileges to user. Adds users to /etc/sudoers file	yes | no	No
use_sudo_nopass	Use password less sudo credes. When enabled user will not be asked for password while running sudo commands.	yes | no	No


Be careful with the update_password setting. When set to always, the user’s password will be changed to what is defined in password. This might not be what they wanted if they’ve manually changed their password so it’s usually safer to use on_create.



exclusive_ssh_key: yes - will remove any ssh keys not defined and no - will append any key specified.



Use encrypted password for password setting. Use Step 8.1 to generate encrypted password.

If the password is not encrypted Ansible gives warning as below

[WARNING]: The input password appears not to have been hashed. The 'password' argument must be encrypted for this module to work properly.

Examples
1: Configuration file for creating one user
---
users:
  - username: alice
    password: $6$/y5RGZnFaD3f$96xVdOAnldEtSxivDY02h.DwPTrJgGQl8/MTRRrFAwKTYbFymeKH/1Rxd3k.RQfpgebM6amLK3xAaycybdc.60
    update_password: on_create
    comment: Test User 100
    shell: /bin/bash
    ssh_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx8crAHG/a9QBD4zO0ZHIjdRXy+ySKviXVCMIJ3/NMIAAzDyIsPKToUJmIApHHHF1/hBllqzBSkPEMwgFbXjyqTeVPHF8V0iq41n0kgbulJG alice@laptop"
    exclusive_ssh_key: yes
    use_sudo: no
    use_sudo_nopass: no
    user_state: present
2: Configuration file for creating multiple user with multiple ssh keys
---
users:
  - username: alice
    password: $6$/y5RGZnFaD3f$96xVdOAnldEtSxivDY02h.DwPTrJgGQl8/MTRRrFAwKTYbFymeKH/1Rxd3k.RQfpgebM6amLK3xAaycybdc.60
    update_password: on_create
    comment: Test User 100
    shell: /bin/bash
    ssh_key: |
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx8crAHG/a9QBD4zO0ZHIjdRXy+ySKviXVCMIJ3/NMIAAzDyIsPKToUJmIApHHHF1/hBllqzBSkPEMwgFbXjyqTeVPHF8V0iq41n0kgbulJG alice@laptop
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx8crAHG/a9QBD4zO0ZHIjdRXy+ySKviXVCMIxxxxxxxxxxxxxxxxxxJmIApHHHF1/hBllqzBSkPEMwgFbXjyqTeVPHF8V0iq41n0kgbulJG alice@server1
    exclusive_ssh_key: yes
    use_sudo: no
    use_sudo_nopass: no
    user_state: present

  - username: bob
    password: $6$XEnyI5UYSw$Rlc6tXtECtqdJ3uFitrbBlec1/8Fx2obfgFST419ntJqaX8sfPQ9xR7vj7dGhQsfX8zcSX3tumzR7/vwlIH6p/
    ssh_key: AAAAB3NzaC1yc2EAAAADAQABAAACAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx8crAHG/a9QBD4zO0ZHIjdRXy+ySKviXVCMIxxxxxxxxxxxxxxxxxxJmIApHHHF1/hBllqbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbulJG bob@laptop
    use_sudo: no
    user_state: present
3: Deleting user
---
users:
  - username: alice
    user_state: absent


  - username: bob
    user_state: absent
9: Run the Ansible Playbook
Once you are done with all the steps above. Run the playbook to add/modify users.

local$ cd infrastructure/user_mgt
local:user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         test.yml        vars


local:user_mgt$ 
Run Ansible command

local:user_mgt$ ansible-playbook create-user.yml -i inventory
Marvel at the output generated by Ansible. Respective action will be taken by Ansible for users.

10: Edit user configuration file
To edit user's configuration file which is vars/lab_users.secret, please use below command

local$ cd infrastructure/user_mgt/


local$ ansible-vault edit vars/lab_users.secret
The tool will launch with default editor vi. edit user configuration as required.

---
users:
  - username: <USERNAME>
    password: <SHA-512 ENCRYPTED PASSWORD>
    update_password: <on_create | always>
    comment: <COMMENT>
    shell: /bin/bash
    ssh_key: "<SSH KEY OF THE USER>"
    exclusive_ssh_key: yes
    use_sudo: <yes|no>
    use_sudo_nopass: <yes|no>
    user_state: <present | absent | lock>
Save and Quit.





Its important not to commit below files in repo. Please add below files to .gitignore

1: infrastructure/user_mgt/.vaultpass

2: infrastructure/user_mgt/vars/lab_users.secret OR infrastructure/user_mgt/vars/*.secret

What does Ansible script do?
When ansible-playbook command has run, below resources, are created.

Resources Created	Managament Instance	App Instances	Worker Instances	Description
Groups	Yes	Yes	Yes	Groups are created if not exist
Users	Yes	Yes	Yes	Users are created if not exist and added to respective groups
SSH key of respective user	Yes	Yes	Yes	SSH key of the user is added on Management , App and Worker instances under ~/.ssh/authorized_keys file
Password	Yes	Yes	Yes	Password is set on all instances.


When a user has created, let's say hellouser, Ansible script generates an ssh key on the Management server for the user. It names the key as "timothy@management" (generally its <username>@management).

hellouser@management$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX hellouser@management


This key is added in the authorized_keys file (/home/hellouser/.ssh/authorized_keys) of the same user (timothy) on the app and worker instances. This allows the user to log in to any of the app and worker instances from the Management server.

hellouser@app1$ cat ~/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX hellouser@management
.


hellouser@worker1$ cat ~/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX hellouser@management
.

The same key is also added in the authorized_keys file (/home/evo/.ssh/authorized_keys) of "evo" user on all app and worker instances. This allows the user to deploy an application from its own account.

hellouser@app1$ cat /home/evo/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX hellouser@management
.


hellouser@worker1$ cat /home/evo/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX hellouser@management
.






