search_criteria = "groups:#{node[:shell_users][:group]}"

search(:users, search_criteria) do |u|

  home_dir = "/home/#{u['id']}"

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['gid'] || u['id']
    mode "0700"
    recursive true
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group u['gid'] || u['id']
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end

end