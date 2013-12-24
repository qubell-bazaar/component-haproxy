#
# Cookbook Name:: haproxy
# Recipe:: add_servers
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node['haproxy']['server'].each do |server|
  bash "add server" do
    cwd "/usr/local/bin"
    code <<-EEND
      ./addServer.sh "#{server}:#{node['haproxy']['port']}" "#{node['haproxy']['bucket']}"
      ./buildConfig.sh
    EEND
  end
end
