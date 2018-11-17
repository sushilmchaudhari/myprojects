## Description

Helps to setup EBA on fresh MAC machines automated by Puppet.

=======

Overview
--------

This is automated by Puppet Configuration Management tool (Masterless setup for independent machine). 

Setup
-----

Simply run install.sh:

```sh
sh install.sh
```

Prerequisites:
-----

### Install Xcode full version 7.

To install Xcode, please use ```Xcode_7.3.1.dmg``` setup kept on Shared device (Codetheory NAS). Double click to install. 

### Install and Configure Git.

El-capitan comes with preinstalled ```git```. Only thing is to configure git. Before configuring you will need a access for a Codetheory Gitlab account on http://git.sic-eba.com to clone eba project on to you machine.

Please follow below steps to configure ```Git```:

https://start.sic-eba.com/wiki/display/EBA/Development+Environment+Setup#DevelopmentEnvironmentSetup-Gitlab

### Install VMWare Fusion.

EBA uses Oracle as Database. In Prod environment we use Linux servers. On Mac machines it is very difficult to install Oracle soft , so we use Virtual machine for Oracle DB. We have created Linux machine image with Oracle DB configured for Dev Env.
You will find Vmware image on Shared Device (Codetheory NAS).

To install VMware fusion and configure :

https://start.sic-eba.com/wiki/display/EBA/Development+Environment+Setup#DevelopmentEnvironmentSetup-VMWareFusion



## Authors/Contributors

[ Sushil Chaudhari ] <sushil@codetheory.io>




## License

Copyright Codehtory.io