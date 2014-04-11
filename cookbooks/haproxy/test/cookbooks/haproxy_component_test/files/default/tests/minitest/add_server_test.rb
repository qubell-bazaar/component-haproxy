require 'minitest/spec'
require 'uri'
require 'digest/md5'

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content #{content}"
end

describe_recipe 'haproxy::add_servers' do
  it "check haproxy.cfg has frontend" do
    url = URI("#{node['haproxy']['bucket']}")
    proto = url.scheme
    frontend_port = url.port
    assert_include_content("/etc/haproxy/haproxy.cfg", "frontend #{proto}-#{frontend_port}")
  end
  it "check haproxy.cfg has default backend config" do
    url = URI("#{node['haproxy']['bucket']}")
    backend_name = Digest::MD5.hexdigest("#{url.scheme}#{url.port}#{url.path}\n")
    assert_include_content("/etc/haproxy/haproxy.cfg", "default_backend #{backend_name}")
  end
  it "check haproxy.cfg has backend config" do
    url = URI("#{node['haproxy']['bucket']}")
    backend_name = Digest::MD5.hexdigest("#{url.scheme}#{url.port}#{url.path}\n")
    assert_include_content("/etc/haproxy/haproxy.cfg", "backend #{backend_name}")
  end
  it "check haproxy.cfg has servers in backend" do
    node['haproxy']['server'].each do |server|
      assert_include_content("/etc/haproxy/haproxy.cfg", "#{server}")
    end
  end
  it "check haproxy.cfg has balance method" do
    url = URI("#{node['haproxy']['bucket']}")
    balance_type = url.host
    assert_include_content("/etc/haproxy/haproxy.cfg", "#{balance_type}")
  end
end
