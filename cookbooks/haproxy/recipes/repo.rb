# ADP repository

case node[:platform]
when "redhat", "centos"
  relnum = node['platform_version'].to_i

  #get the metadata
  execute "yum -q makecache" do
    action :nothing
  end
  #reload internal Chef yum cache
  ruby_block "reload-internal-yum-cache" do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
    action :nothing
  end

  #write out the file
  template "/etc/yum.repos.d/ADP.repo" do
    source "ADP.repo.erb"
    mode "0644"
    variables({
                :relnum => relnum
              })
    notifies :run, resources(:execute => "yum -q makecache"), :immediately
    notifies :create, resources(:ruby_block => "reload-internal-yum-cache"), :immediately
  end
  
end

