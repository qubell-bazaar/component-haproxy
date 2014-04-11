include_recipe "haproxy"
include_recipe "haproxy::add_servers"
include_recipe "haproxy::del_servers"
include_recipe "minitest-handler"
