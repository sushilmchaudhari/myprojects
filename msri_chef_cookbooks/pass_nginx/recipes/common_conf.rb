#
# Cookbook:: pass_nginx
# Recipe:: common_conf
#
# Copyright:: 2018, The Authors, All Rights Reserved.

cookbook_file "/tmp/config_path.sh" do
  owner "root"
  group "root"
  mode 0755
end

bash "config_path" do
  code "/tmp/config_path.sh #{node[:rvm][:gemset].last} #{node[:passenger][:production][:path]}/conf/nginx.conf.unpatched #{node[:passenger][:production][:path]}/conf/nginx.conf"
  action :nothing
  notifies :restart, 'service[nginx]'
end

# Template conf file

if node['nginx']['conf']['default'] 
   source_file = "nginx.conf.erb"
else
   source_file = "web.nginx.conf.erb"
end

template "#{node[:passenger][:production][:path]}/conf/nginx.conf.unpatched" do
  source "#{source_file}"
  mode 0644
  variables(
    :passenger_root => "##PASSENGER_ROOT##",
    :ruby_path => "#{node[:rvm][:path]}/wrappers/default/ruby",
  )
  notifies :run, 'bash[config_path]'
end


