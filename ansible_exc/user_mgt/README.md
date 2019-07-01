
-   [SSH User Management](#UserManagement-SSHUserManagement)
    -   [1: Install Python3](#UserManagement-1:InstallPython3)
    -   [2: Install Ansible](#UserManagement-2:InstallAnsible)
    -   [3: Validate
        Installation](#UserManagement-3:ValidateInstallation)
    -   [4: Clone Ansible scripts from Git
        Repo](#UserManagement-4:CloneAnsiblescriptsfromGitRepo)
    -   [5: Setup Ansible Vault](#UserManagement-5:SetupAnsibleVault)
        -   [1: Create a vault password
            file](#UserManagement-1:Createavaultpasswordfile)
        -   [2: Add .vaultpass to
            Gitignore](#UserManagement-2:Add.vaultpasstoGitignore)
    -   [6: Configure ssh for
        Ansible](#UserManagement-6:ConfiguresshforAnsible)
    -   [7: Setup Inventory for
        Ansible](#UserManagement-7:SetupInventoryforAnsible)
    -   [8: Create configuration for
        user](#UserManagement-8:Createconfigurationforuser)
        -   [1: Generate User
            password](#UserManagement-1:GenerateUserpassword)
        -   [2: Create Configuration
            file](#UserManagement-2:CreateConfigurationfile)
            -   [User Settings:](#UserManagement-UserSettings:)
            -   [Examples](#UserManagement-Examples)
                -   [1: Configuration file for creating one
                    user](#UserManagement-1:Configurationfileforcreatingoneuser)
                -   [2: Configuration file for creating multiple user
                    with multiple ssh
                    keys](#UserManagement-2:Configurationfileforcreatingmultipleuserwithmultiplesshkeys)
                -   [3: Deleting user](#UserManagement-3:Deletinguser)
    -   [9: Run the
        Ansible Playbook](#UserManagement-9:RuntheAnsiblePlaybook)
    -   [10: Edit user configuration
        file](#UserManagement-10:Edituserconfigurationfile)
-   [What does Ansible script
    do?](#UserManagement-WhatdoesAnsiblescriptdo?)

SSH User Management
===================

This manages users in the user list configuration file (list is in the
file vars/lab\_users.secret in the example below). It can add users,
delete users, change passwords, lock/unlock user accounts, manage sudo
access (per user), add ssh key(s) for ssh key based authentication.

1: Install Python3
------------------

If you don't have python3 installed, Please follow the instructions from
below link with respect to the flavour of OS you are using to install
python3.

<a href="https://realpython.com/installing-python/#macos-mac-os-x" class="external-link">https://realpython.com/installing-python/#macos-mac-os-x</a>

2: Install Ansible
------------------

<span
style="color: rgb(33,37,41);">The </span><a href="https://www.cyberciti.biz/faq/debian-ubuntu-centos-rhel-linux-install-pipclient/" class="external-link">pip command is a tool for installing and managing Python packages</a><span
style="color: rgb(33,37,41);">, such as those found in the Python
Package Index. The following method works on Linux and Unix-like
systems</span>

``` syntaxhighlighter-pre
local$ sudo pip install ansible
```

<span
class="aui-icon aui-icon-small aui-iconfont-info confluence-information-macro-icon"></span>

For more reference on Ansible installation , please refer
<a href="https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html" class="external-link">https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html</a>

3: Validate Installation
------------------------

After installing Ansible, validate the installation using below command.

``` syntaxhighlighter-pre
local$ ansible --version
ansible 2.8.1
  config file = None
  configured module search path = ''
  ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.7.3 (default, May 10 2019, 12:08:37) [Clang 10.0.1 (clang-1001.0.46.3)]
```

4: Clone Ansible scripts from Git Repo
--------------------------------------

Clone the terraform scripts from git repo.

``` syntaxhighlighter-pre
local$ git clone <git-repo.git>
```

Change to 

``` syntaxhighlighter-pre
local$ cd infrastructure/user_mgt
user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         vars
user_mgt$ 
```

5: Setup Ansible Vault
----------------------

Ansible Vault uses AES encryption to store your sensitive information.
And we need Ansible Vault to encrypt our user configuration file since
we don’t want to be exposing even a hashed password into source control.
You will need to set it up.

### 1: Create a vault password file

Create a password for your Ansible Vault by creating the .vaultpass
file, add the Vault password, and fix the permissions:

``` syntaxhighlighter-pre
local@user_mgt$ echo "<your_secret_password>" > .vaultpass
local@user_mgt$ chmod 600 .vaultpass
```

### 2: Add .vaultpass to Gitignore

Make sure to update your .gitignore file so your Vault password isn’t
saved to your source control. And also add the secret file we will be
creating later:

``` syntaxhighlighter-pre
local$ cd <git cloned directory>


local$ ls -a .gitignore
.gitignore


local$ echo "infrastructure/user_mgt/.vaultpass" >> .gitignore
```

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

The ansible config file is already updated to reference where the Vault
file is located. You can check the ansible configuration file

<span class="s1">infrastructure/user\_mgt/ansible.cfg</span>

  

6: Configure ssh for Ansible
----------------------------

The app/worker instances are accessible only through Management server.
We need this configuration for ansible to connect to app and worker
instances through Management.

**1: Open ssh.cfg**

``` syntaxhighlighter-pre
local$ cd infrastructure/user_mgt
local:user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         test.yml        vars


local:user_mgt$ vi ssh.cfg
```

**2: Edit file with necessary values**

``` syntaxhighlighter-pre
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
```

**3: Save and Quit**

7: Setup Inventory for Ansible
------------------------------

**1: Open inventory file**

``` syntaxhighlighter-pre
local$ cd infrastructure/user_mgt
local:user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         test.yml        vars


local:user_mgt$ vi inventory
```

**2: Edit file with necessary values**

``` syntaxhighlighter-pre
[mgt]
<MANAGEMENT INSTANCE IP>

[app]
<APP INSTANCE IP ADDRESSES>

[worker]
<WORKER INSTANCE IP ADDRESSES>
```

For eg:

``` syntaxhighlighter-pre
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
```

**3: Save and Quit**

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

You can find Management, App and Worker instance Ip addresses in
terraform output. [Setting up Terraform
Project](https://start.clearstack.io/wiki/display/NFG/Setting+up+Terraform+Project)

8: Create configuration for user
--------------------------------

Next, add your users into a configuration file. The below is only an
example, 

### 1: Generate User password

Ansible needs User password to be encrypted in specific format. Please
follow the instruction to create encrypted password and use in
configuration file.

a: Open
link <a href="https://www.mkpasswd.net/index.php" class="external-link">https://www.mkpasswd.net/index.php</a>

b: Enter required details

-   <span style="color: rgb(0,0,0);">**Password** -  Password in plain
    text. Password is not visible in text box. So careful while typing
    password. For Eg: hello123</span>  
-   <span style="color: rgb(0,0,0);"><span
    style="color: rgb(0,0,0);">**Type**          -  Select **crypt -
    sha512**</span>  
    </span>
-   <span style="color: rgb(0,0,0);"><span
    style="color: rgb(0,0,0);">Leave <span
    style="color: rgb(0,0,0);">**Category** as
    blank.</span></span></span>
-   <span style="color: rgb(0,0,0);"><span
    style="color: rgb(0,0,0);"><span style="color: rgb(0,0,0);">Click on
    **Hash** button to generate encrypted password.</span></span></span>

<span style="color: rgb(0,0,0);"><span style="color: rgb(0,0,0);"><span
style="color: rgb(0,0,0);">c: An encrypted password is available
in <span style="color: rgb(0,0,0);">**Hashed** text
box.</span></span></span></span>

### 2: Create Configuration file

There is special command to create configuration file. Please use below
command to create configuration file.

``` syntaxhighlighter-pre
local$ cd infrastructure/user_mgt/


local$ ansible-vault create vars/lab_users.secret
```

<span style="color: rgb(64,64,64);">The tool will launch with default
editor vi. Add user configuration like below</span>

``` syntaxhighlighter-pre
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
```

Save and Quit.

#### User Settings:

<table>
<thead>
<tr class="header">
<th>Settings</th>
<th>Description</th>
<th>Allowed Values</th>
<th>Required</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>username</td>
<td>User name with no spaces</td>
<td><br />
</td>
<td>Yes</td>
</tr>
<tr class="even">
<td>user_state</td>
<td>State of the user</td>
<td><p><strong>present</strong> - To add user</p>
<p><strong>absent</strong> - To delete user</p>
<p><strong>lock</strong> - To lock user</p></td>
<td>Yes</td>
</tr>
<tr class="odd">
<td>password</td>
<td><p>Sha-512 encrypted password of the user.</p>
<p>If the password field is not defined, "!" is set</p></td>
<td><br />
</td>
<td>No</td>
</tr>
<tr class="even">
<td>update_password</td>
<td>When to update password</td>
<td><p><strong>on_create</strong> - update password only while creating user</p>
<p><strong>always</strong> - every time when script is run</p></td>
<td>No</td>
</tr>
<tr class="odd">
<td><span style="color: rgb(36,41,46);">comment</span></td>
<td><span style="color: rgb(36,41,46);">Full name and Department or description of application</span></td>
<td><br />
</td>
<td>No</td>
</tr>
<tr class="even">
<td><span style="color: rgb(36,41,46);">groups</span></td>
<td><span style="color: rgb(36,41,46);">Comma separated list of groups the user will be added to</span></td>
<td><br />
</td>
<td>No</td>
</tr>
<tr class="odd">
<td><span style="color: rgb(36,41,46);">shell</span></td>
<td><span style="color: rgb(36,41,46);">path to shell. <span style="color: rgb(36,41,46);">default is /bin/bash</span></span></td>
<td><br />
</td>
<td>No</td>
</tr>
<tr class="even">
<td><span style="color: rgb(36,41,46);">ssh_key</span></td>
<td>User's <span style="color: rgb(36,41,46);">ssh key for ssh key based authentication</span></td>
<td><br />
</td>
<td>No</td>
</tr>
<tr class="odd">
<td><span style="color: rgb(36,41,46);">exclusive_ssh_key</span></td>
<td><p><span style="color: rgb(64,64,64);">Whether to remove all other non-specified keys from the authorized_keys file.</span></p>
<p><span style="color: rgb(64,64,64);">Default is no. Recommended not to change this</span></p></td>
<td><p><strong>yes |</strong> <strong>no</strong></p></td>
<td>No</td>
</tr>
<tr class="even">
<td><span style="color: rgb(36,41,46);">sudo</span></td>
<td>Allow admin privileges to user. Adds users to /etc/sudoers file</td>
<td><strong>yes | no</strong></td>
<td>No</td>
</tr>
<tr class="odd">
<td><span style="color: rgb(36,41,46);">use_sudo_nopass</span></td>
<td>Use password less sudo credes. When enabled user will not be asked for password while running sudo commands.</td>
<td><strong>yes | no</strong></td>
<td>No</td>
</tr>
</tbody>
</table>

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

Be careful with the `update_password` setting. When set to `always`, the
user’s password will be changed to what is defined in `password`. This
might not be what they wanted if they’ve manually changed their password
so it’s usually safer to use `on_create`.

  

<span style="color: rgb(36,41,46);">exclusive\_ssh\_key: yes - will
remove any ssh keys not defined and no - will append any key
specified.</span>

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

Use encrypted password for password setting. Use **Step 8.1** to
generate encrypted password.

If the password is not encrypted Ansible gives warning as below

<span class="s1">**\[WARNING\]: The input password appears not to have
been hashed. The 'password' argument must be encrypted for this module
to work properly.**</span>

#### Examples

##### 1: Configuration file for creating one user

``` syntaxhighlighter-pre
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
```

##### <span style="color: rgb(112,112,112);">2: Configuration file for creating multiple user with multiple ssh keys</span>

``` syntaxhighlighter-pre
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
```

##### 3: Deleting user

``` syntaxhighlighter-pre
---
users:
  - username: alice
    user_state: absent


  - username: bob
    user_state: absent
```

9: Run the Ansible Playbook
---------------------------

Once you are done with all the steps above. Run the playbook to
add/modify users.

``` syntaxhighlighter-pre
local$ cd infrastructure/user_mgt
local:user_mgt$ ls 
ansible.cfg     create-user.yml inventory       roles           ssh.cfg         test.yml        vars


local:user_mgt$ 
```

Run Ansible command

``` syntaxhighlighter-pre
local:user_mgt$ ansible-playbook create-user.yml -i inventory
```

Marvel at the output generated by Ansible. Respective action will be
taken by Ansible for users.

10: Edit user configuration file
--------------------------------

To edit user's configuration file which is **vars/lab\_users.secret**,
please use below command

``` syntaxhighlighter-pre
local$ cd infrastructure/user_mgt/


local$ ansible-vault edit vars/lab_users.secret
```

<span style="color: rgb(64,64,64);">The tool will launch with default
editor vi. edit user configuration as required.</span>

``` syntaxhighlighter-pre
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
```

Save and Quit.

  

  

<span
class="aui-icon aui-icon-small aui-iconfont-warning confluence-information-macro-icon"></span>

Its important not to commit below files in repo. Please add below files
to .gitignore

1: infrastructure/user\_mgt/.vaultpass

2: infrastructure/user\_mgt/vars/lab\_users.secret OR
infrastructure/user\_mgt/vars/\*.secret

What does Ansible script do?
============================

When ansible-playbook command has run, below resources, are created.

| Resources Created          | Managament Instance | App Instances | Worker Instances | Description                                                                                               |
|----------------------------|---------------------|---------------|------------------|-----------------------------------------------------------------------------------------------------------|
| Groups                     | Yes                 | Yes           | Yes              | Groups are created if not exist                                                                           |
| Users                      | Yes                 | Yes           | Yes              | Users are created if not exist and added to respective groups                                             |
| SSH key of respective user | Yes                 | Yes           | Yes              | SSH key of the user is added on Management , App and Worker instances under \~/.ssh/authorized\_keys file |
| Password                   | Yes                 | Yes           | Yes              | Password is set on all instances.                                                                         |

  

When a user has created, let's say timothy, Ansible script generates an
ssh key on the Management server for the user. It names the key as
"timothy@management" (generally its \<username\>@management).

``` syntaxhighlighter-pre
timothy@management$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX timothy@management
```

  

This key is added in the authorized\_keys file
(/home/timothy/.ssh/authorized\_keys) of the same user (timothy) on the
app and worker instances. This allows the user to log in to any of the
app and worker instances from the Management server.

``` syntaxhighlighter-pre
timothy@app1$ cat ~/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX timothy@management
.
```

``` syntaxhighlighter-pre
timothy@worker1$ cat ~/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX timothy@management
.
```

  
The same key is also added in the authorized\_keys file
(/home/evo/.ssh/authorized\_keys) of "evo" user on all app and worker
instances. This allows the user to deploy an application from its own
account.

``` syntaxhighlighter-pre
timothy@app1$ cat /home/evo/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX timothy@management
.
```

  

``` syntaxhighlighter-pre
timothy@worker1$ cat /home/evo/.ssh/authorized_keys
.
ssh-rsa AAAAB3Nza XXXXXXXXXXXXXXXXXXX timothy@management
.
```
