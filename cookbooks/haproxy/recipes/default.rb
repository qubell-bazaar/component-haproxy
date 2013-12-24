#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

service "haproxy" do
  supports :status => true, :restart => true
end

if platform_family?('rhel')
  include_recipe "yum"
  include_recipe "yum::epel"
end

package "haproxy" do
  action :install
end
  
case node[:platform]
when "debian", "ubuntu"
  bash "enable haproxy" do
    code <<-EEND
      echo 'ENABLED=1' > /etc/default/haproxy
    EEND
    only_if { File.exists? "/etc/default/haproxy" }
  end
end

template "/etc/haproxy/global.cfg" do
  source "global.cfg.erb"
  variables({
    :stats_user => node['haproxy']['stats_user'],
    :stats_pass => node['haproxy']['stats_pass'],
    :stats_uri => node['haproxy']['stats_uri'],
    :stats_port => node['haproxy']['stats_port'],
  })
end

cookbook_file "/usr/local/bin/buildConfig.sh" do
  source "buildConfig.sh"
  owner "root"
  group "root"
  mode 00744
end

cookbook_file "/usr/local/bin/addServer.sh" do
  source "addServer.sh"
  owner "root"
  group "root"
  mode 00744
end

cookbook_file "/usr/local/bin/delServer.sh" do
  source "delServer.sh"
  owner "root"
  group "root"
  mode 00744
end

cookbook_file "/usr/local/bin/delServers.sh" do
  source "delServers.sh"
  owner "root"
  group "root"
  mode 00744
end

bash "generate haproxy.cfg" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./buildConfig.sh
  EEND
  notifies :restart, "service[haproxy]"
end

if platform_family?('rhel')
  execute "stop iptables" do
    command "/etc/init.d/iptables stop"
  end
end

if platform_family?('debian')
  execute "stop iptables" do
    command "iptables -F"
  end
end
