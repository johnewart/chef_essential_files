search_criteria = "groups:#{node[:shell_users][:group]}"

search(:users, search_criteria) do |u|

  home_dir = "/home/#{u['id']}"

  # fixes CHEF-1699
  ruby_block "reset group list" do
    block do
      Etc.endgrent
    end
    action :nothing
  end

  user u['id'] do
    uid u['uid']
    gid u['gid']
    shell u['shell']
    comment u['comment']
    supports :manage_home => true
    home home_dir
    notifies :create, "ruby_block[reset group list]", :immediately
  end
  
end
