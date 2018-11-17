#
# Cookbook:: rvm_ruby
# Recipe:: install_rvm
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe "build-essential"

rvm_cmd = "#{node[:rvm][:path]}/bin/rvm"

package "curl"
package "git-core"

execute 'detect_rvm_current_version' do
  command "#{rvm_cmd} version"
  only_if "test -e #{rvm_cmd}"
end

remote_file "#{node[:rvm][:temp][:path]}/rvm-installer.sh" do
  source "#{node[:rvm][:installer]}"
  mode '0755'
  action :create_if_missing
end

execute 'import_gpg_keys' do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys #{node[:rvm][:gpg_keys]}"
  only_if { node[:rvm][:gpg_keys] != '' }
  not_if "test -e #{rvm_cmd}"
  ignore_failure true
end

execute 'import_gpg_key_other_way' do
  command "curl -sSL https://rvm.io/mpapis.asc | gpg --import -"
  only_if { node[:rvm][:gpg_keys] != '' }
  not_if "test -e #{rvm_cmd}"
end

execute 'install_rvm' do
  command <<-EOL
    #{node[:rvm][:temp][:path]}/rvm-installer.sh #{node[:rvm][:version]} --path #{node[:rvm][:path]} --auto-dotfiles
EOL
  not_if "test -e #{rvm_cmd}"
end


if File.file?( rvm_cmd ) && node[:rvm][:update]
  bash 'update_rvm' do
    code "#{rvm_cmd} get #{node[:rvm][:version]} && #{rvm_cmd} reload"
  end
end

execute 'configure_rvm' do
  command "#{rvm_cmd} autolibs 3"
  only_if "test -e #{rvm_cmd}"
end

magic_shell_environment 'PATH' do 
  value "$PATH:#{node[:rvm][:path]}/bin" 
end

group 'rvm' do
  members ['msri', 'sushil', 'ubuntu', 'ajaya', 'bala']
  append true
end
