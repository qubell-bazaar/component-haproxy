#
# Cookbook Name:: haproxy
# Recipe:: del_server 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "del server" do
  cwd "/usr/local/bin"
  code <<-EEND
    ./delServer.sh "#{node['haproxy']['server']}" "#{node['haproxy']['bucket']}"
    ./buildConfig.sh
  EEND
end
