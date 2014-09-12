define :tornado_application do
  app_name = params[:name]
  app_root = params[:app_root]
  app_user = params[:user]
  app_group = params[:group]
  
  python_interpreter = params[:python_interpreter] || 
                       "/usr/bin/python3.3"
  github_repo = params[:github_repo] 
  deploy_branch = params[:deploy_branch] || "deploy"

  virtualenv = "#{app_root}/python"
  virtual_python = "#{virtualenv}/bin/python"
  app_dir = "#{app_root}/src/#{app_name}"

  # Need to install SSH key for GitHub
  # this comes from the ssh_known_hosts cookbook
  ssh_known_hosts_entry 'github.com'

  # Base package requirements
  package "git"
  package "libpq-dev"
  package "libxml2-dev"
  package "python3.3"
  package "python3.3-dev"
    
  directory "#{app_root}" do
    owner "#{app_user}"
    group "#{app_group}"
    mode "0755"
    action :create
    recursive true
  end

  # Create directories
  ["bin", "src", "logs", "conf", "tmp"].each do |child_dir|
    directory "#{app_root}/#{child_dir}" do
      owner "#{app_user}"
      group "#{app_group}"
      mode "0755"
      action :create
      recursive true
    end
  end


  # Install Python virtualenv
  python_virtualenv "#{virtualenv}" do 
    owner "#{app_user}"
    group "#{app_group}"
    action :create 
    interpreter "#{python_interpreter}"
  end

  # Application checkout
  git "#{app_dir}" do
    repository "#{github_repo}"
    action :sync
    user "#{app_user}"
    branch "#{deploy_branch}"
  end

  # Python dependencies for app
  pip_requirements "tornado_app[#{app_name}]" do
    action :run
    pip "#{virtualenv}/bin/pip"
    user "#{app_user}"
    group "#{app_group}"
    requirements_file "#{app_dir}/requirements.txt"
  end

end
