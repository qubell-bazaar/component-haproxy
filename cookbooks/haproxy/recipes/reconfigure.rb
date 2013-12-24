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

node['haproxy']['server'].each do |server|
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{server}:#{node['haproxy']['port']}" "#{node['haproxy']['bucket']}"
      ./buildConfig.sh
    EEND
  end
end
