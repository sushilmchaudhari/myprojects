#
# Cookbook:: backend
# Recipe:: nfs
#
# Copyright:: 2017, The Authors, All Rights Reserved.

%w(nfs::_common nfs::server nfs::_idmap).each do |component|
  include_recipe component
end

nfs_export "/exports" do
  network '10.0.0.0/8'
  writeable false 
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/extra/webfiles/attachments" do
  network '10.17.0.0/16'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/extra/webfiles/people/staff" do
  network '10.17.0.0/16'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/extra" do
  network '10.17.3.0/24'
  writeable false
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/extra" do
  network '10.17.4.0/24'
  writeable false
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/extra" do
  network '10.17.5.0/24'
  writeable false
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/servers/web" do
  network '10.17.3.0/24'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/servers/db" do
  network '10.17.15.0/24'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/servers/staging" do
  network '10.17.5.0/24'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end


nfs_export "/servers" do
  network '10.17.3.0/24'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end

nfs_export "/servers" do
  network '10.17.5.0/24'
  writeable true
  sync false
  options ['no_root_squash', 'no_subtree_check']
end
