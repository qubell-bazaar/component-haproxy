#
# Cookbook Name:: haproxy
# Recipe:: reconfigure 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "delete servers" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./delServers.sh "#{node['haproxy']['bucket']}"
 EEND
end

ssl_cert="#{Chef::Config[:file_cache_path]}/cert.pem"
if ( !node['haproxy']['ssl_cert'].nil? )
  if "#{node['haproxy']['ssl_cert']}".match("^(http|ftp)")
    remote_file ssl_cert do
      source "#{node['haproxy']['ssl_cert']}"
    end
  else
    file ssl_cert do
      content node['haproxy']['ssl_cert']
      mode 00644
      owner "root"
      group "root"
      action :create
    end
  end
else
  ssl_cert=""
end

node['haproxy']['server'].each do |server|
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{server}:#{node['haproxy']['port']}" "#{node['haproxy']['bucket']}" "#{ssl_cert}"
      ./buildConfig.sh
    EEND
  end
end
