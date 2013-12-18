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

haproxy_version = "1.5-dev19-0ubuntu1~precise"
case node[:platform]
when "debian", "ubuntu"
  include_recipe "apt"
  apt_repository "haproxy" do
    uri "http://ppa.launchpad.net/nilya/haproxy-1.5/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "A6D3315B"
  end

  package "haproxy" do
    version haproxy_version
    action :install
  end
  
  bash "enable haproxy" do
    code <<-EEND
      echo 'ENABLED=1' > /etc/default/haproxy
    EEND
    only_if { File.exists? "/etc/default/haproxy" }
  end

when "centos"
  if node['platform_version'].to_f < 6.0
    remote_file "/tmp/haproxy.rpm" do
      source "http://silverdire.com/files/repo/el5/x86_64/haproxy-1.5-dev19.el5.x86_64.rpm"
      action :create
    end
    rpm_package "haproxy.rpm" do
      source "/tmp/haproxy.rpm"
      action :install    
    end
  end
  if node['platform_version'].to_f > 6.0
    remote_file "/tmp/haproxy-1.5-dev19.el6.x86_64.rpm" do
      source "http://silverdire.com/files/repo/el6/x86_64/haproxy-1.5-dev19.el6.x86_64.rpm"
      action :create_if_missing
    end
    rpm_package "haproxy-1.5-dev.rpm" do
      source "/tmp/haproxy-1.5-dev19.el6.x86_64.rpm"
      action :install
    end
  end
end

stats_cert="/etc/haproxy/stats.pem"
if ( !node['haproxy']['stats_cert'].nil? )
  if "#{node['haproxy']['stats_cert']}".match("^(http|ftp)")
    #remote_file "#{Chef::Config[:file_cache_path]}/stats.pem" do
    remote_file stats_cert do
      source "#{node['haproxy']['stats_cert']}"
    end
  else
    # File content
    file stats_cert do
      content node['haproxy']['stats_cert']
      mode 00644
      owner "root"
      group "root"
      action :create
    end
  end
else
  if ( ! node['cloud'].nil? ) &&( ! node['cloud']['public_hostname'].nil? )
    hostname = node.cloud.public_hostname
  else
    hostname = node.fqdn
  end
  bash "generate #{stats_cert}" do
    not_if { File.exists? stats_cert }
    code <<-EEND
      openssl genrsa -out #{stats_cert}.key 2048
      openssl req -new -x509 -extensions v3_ca -days 1100 -subj "/CN=#{hostname}" -nodes -out #{stats_cert} -key #{stats_cert}.key
      cat #{stats_cert}.key >> #{stats_cert}
    EEND
  end
end

template "/etc/haproxy/global.cfg" do
  source "global.cfg.erb"
  variables({
    :stats_user => node['haproxy']['stats_user'],
    :stats_pass => node['haproxy']['stats_pass'],
    :stats_uri => node['haproxy']['stats_uri'],
    :stats_port => node['haproxy']['stats_port'],
    :stats_cert => stats_cert,
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
