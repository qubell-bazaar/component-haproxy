include_recipe "rsyslog"

template "#{node['rsyslog']['config_prefix']}/rsyslog.d/49-haproxy.conf" do
  source "49-haproxy.conf.erb"
end
