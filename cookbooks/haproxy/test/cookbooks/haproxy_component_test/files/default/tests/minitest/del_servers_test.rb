require 'minitest/spec'
require 'uri'
require 'digest/md5'

def refute_include_content(file, content)
  refute File.read(file).include?(content), "Expected file '#{file}' not include the specified content #{content}"
end

describe_recipe 'haproxy::del_servers' do
  it "check haproxy.cfg  don't have specified servers " do
    node['haproxy']['server'].each do |server|
      refute_include_content("/etc/haproxy/haproxy.cfg", "#{server}")
    end
  end
end
