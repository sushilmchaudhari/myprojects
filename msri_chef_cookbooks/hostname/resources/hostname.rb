provides :hostname
resource_name :hostname

property :hostname, String, name_property: true
property :ipaddress, [ String, nil ], default: node["ipaddress"]
property :aliases, [ Array, nil ], default: nil

default_action :set

action_class do
  def append_replacing_matching_lines(path, regex, string)
    text = IO.read(path).split("\n")
    text.reject! { |s| s =~ regex }
    text += [ string ]
    file path do
      content text.join("\n") + "\n"
      owner "root"
      group node["root_group"]
      mode "0644"
      not_if { IO.read(path).split("\n").include?(string) }
    end
  end
end

action :set do
  ohai "reload hostname" do
    plugin "hostname"
    action :nothing
  end

  # set the hostname via /bin/hostname
  execute "set hostname to #{new_resource.hostname}" do
    command "/bin/hostname #{new_resource.hostname}"
    not_if { shell_out!("hostname").stdout.chomp == new_resource.hostname }
    notifies :reload, "ohai[reload hostname]"
  end

  # make sure node['fqdn'] resolves via /etc/hosts
  unless new_resource.ipaddress.nil?
    newline = "#{new_resource.ipaddress} #{new_resource.hostname}"
    newline << " #{new_resource.aliases.join(" ")}" if new_resource.aliases && !new_resource.aliases.empty?
    newline << " #{new_resource.hostname[/[^\.]*/]}"
    r = append_replacing_matching_lines("/etc/hosts", /^#{new_resource.ipaddress}\s+|\s+#{new_resource.hostname}\s+/, newline)
    r.atomic_update false if docker?
    r.notifies :reload, "ohai[reload hostname]"
  end

  file "/etc/hostname" do
    atomic_update false if docker?
    content "#{new_resource.hostname}\n"
    owner "root"
    group node["root_group"]
    mode "0644"
  end
end
