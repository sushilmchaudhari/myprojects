#
# Cookbook:: database
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Set hostname as 
hostname "support.msri.org"

# Install and configure OpenLDAP
include_recipe "backend::ldap"

# Install and configure Postfix email service with AWS SES integration
include_recipe "backend::email"

# Install and Configure SOLR (Index)
include_recipe "backend::solr"

# Install and confgure NFS
include_recipe "backend::nfs"

# Install and Configure NewRelic
include_recipe "m_newrelic::default"
