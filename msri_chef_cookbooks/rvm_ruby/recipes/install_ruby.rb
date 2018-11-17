#
# Cookbook:: rvm_ruby
# Recipe:: install_ruby
#
# Copyright:: 2017, The Authors, All Rights Reserved.


# Local attributes

default_ruby_version = node[:rvm][:install][:rubies].last
rvm_cmd = "#{node[:rvm][:path]}/bin/rvm"


# Install required packages

%w(bzip2 gawk g++ gcc make libc6-dev zlib1g-dev libyaml-dev libsqlite3-dev sqlite3 libgmp-dev libgdbm-dev libncurses5-dev automake libtool pkg-config libffi-dev libgmp-dev libreadline6-dev libssl-dev).each do |pkg|
  package pkg
end

# Install Ruby versions

node[:rvm][:install][:rubies].each do |ruby|
  execute 'install_ruby' do
    command "#{rvm_cmd} install #{ruby}" 
    not_if "#{rvm_cmd} list | grep #{ruby}"
  end
end

# Select default version

bash "select_default_version" do
  code "#{rvm_cmd} --default #{default_ruby_version}"
  code "#{rvm_cmd} alias create default #{default_ruby_version}"
  not_if "#{rvm_cmd} list | grep '=> #{default_ruby_version}'"
end

# Create gemset for default ruby

node[:rvm][:gemset].each do |set|
  execute 'create_gemsets_under_default_ruby' do
    command "#{rvm_cmd} gemset create #{set}" 
    not_if "#{rvm_cmd} gemset list | grep #{set}"
  end
end

# Install bundler under all ruby versions

node[:rvm][:install][:rubies].each do |ruby|
  bash 'install_bundler' do
    code <<-EOL
      #{node[:rvm][:path]}/wrappers/#{ruby}/gem install bundler
    EOL
    creates "#{node[:rvm][:path]}/wrappers/#{ruby}/bundler"
    not_if "test -e #{node[:rvm][:path]}/wrappers/#{ruby}/bundler"
  end
end

# Create symbolic links to default ruby binaries

node[:rvm][:ruby][:binaries].each do |file| 
  link "/usr/local/bin/#{file}" do
    to "#{node[:rvm][:path]}/wrappers/default/#{file}"
    link_type :symbolic
    action :create
  end
end

# Delete Ruby 

if !node[:rvm][:delete][:rubies].empty?
node[:rvm][:delete][:rubies].each do |ruby|
  execute 'remove_ruby_versions'
    command "#{rvm_cmd} remove #{ruby}"
    only_if "#{rvm_cmd} list | grep #{ruby}"
  end
else
  log "No ruby version to remove"
end
