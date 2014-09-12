search_criteria = "groups:#{node[:deploy_users][:group]}"

search(:users, search_criteria) do |u|
  home_dir = "/home/#{u['id']}"

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['gid'] || u['id']
    mode "0700"
    recursive true
  end

  template "#{home_dir}/.ssh/id_rsa" do 
    source "deploy_key.erb"
    owner u['id']
    group u['gid'] || u['id']
    mode "0600"
    variables :key => u['deploy_key']
  end
end