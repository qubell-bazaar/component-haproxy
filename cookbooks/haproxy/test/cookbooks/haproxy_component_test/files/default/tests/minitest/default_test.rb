require 'minitest/spec'

sleep(20)
require 'socket'
require 'timeout'
def is_port_open?(ip, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(ip, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  rescue Timeout::Error
  end

  return false
end

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content"
end

describe_recipe 'haproxy::default' do
  it "haproxy is listening" do
    assert is_port_open?("#{node["ipaddress"]}", "#{node["haproxy"]["stats_port"]}") == true, "Expected port #{node["haproxy"]["stats_port"]} is open"
  end
  it "install haproxy package" do
    package("haproxy").must_be_installed
  end
  it "haproxy is running" do
    service("haproxy").must_be_running
  end
  it "firewall must be disabled" do
    if node["platform_family"] == 'rhel'
      service("iptables").wont_be_running
    end
  end
  it "creates buildConfig.sh" do
    file("/usr/local/bin/buildConfig.sh").must_exist
  end
  it "creates /usr/local/bin/addServer.sh" do
    file("/usr/local/bin/addServer.sh").must_exist
  end
  it "creates delServer.sh" do
    file("/usr/local/bin/delServer.sh").must_exist
  end
  it "creates delServers.sh" do
    file("/usr/local/bin/delServers.sh").must_exist
  end
  it "creates /etc/haproxy/haproxy.cfg" do
    file("/etc/haproxy/haproxy.cfg").must_exist
  end
  it "check global.cfg has correct owner and mode" do
    assert_file "/etc/haproxy/haproxy.cfg", "root", "root", "644"
  end
  it "check buildConfig.sh has correct owner and mode" do
    assert_file "/usr/local/bin/buildConfig.sh", "root", "root", "744"
  end
  it "check addServer.sh has correct owner and mode" do
    assert_file "/usr/local/bin/addServer.sh", "root", "root", "744"
  end
  it "check delServer.sh has correct owner and mode" do
    assert_file "/usr/local/bin/delServer.sh", "root", "root", "744"
  end
  it "check delServers.sh has correct owner and mode" do
    assert_file "/usr/local/bin/delServers.sh", "root", "root", "744"
  end
  it "check haproxy.cfg has correct content" do
    assert_include_content("/etc/haproxy/haproxy.cfg", "#{node['haproxy']['stats_user']}")
    assert_include_content("/etc/haproxy/haproxy.cfg", "#{node['haproxy']['stats_pass']}")
    assert_include_content("/etc/haproxy/haproxy.cfg", "#{node['haproxy']['stats_uri']}")
    assert_include_content("/etc/haproxy/haproxy.cfg", "#{node['haproxy']['stats_port']}")
  end
  it "check haproxy is enabled" do
    if node["platform_family"] == 'debian'
      assert_include_content("/etc/default/haproxy", "ENABLED=1")
    end
  end
end

