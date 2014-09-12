##
# Installs a python virtualenv, the app and any
# specified packages that the application needs.
#

app_root = node[:webapp][:install_path]
python_interpreter = node[:webapp][:python]
virtualenv = "#{app_root}/python"
virtual_python = "#{virtualenv}/bin/python"
src_dir = "#{app_root}/src/"
# Grab the first database host
dbhost = search(:node, "role:postgresql_server")[0]['ipaddress']

environment_hash = {
  "HOME" => "#{app_root}",
  "PYTHONPATH" => "#{app_root}/src"
}

# Need to install SSH key for github.com
ssh_known_hosts_entry 'github.com'

# Base package requirements
package "git"
package "libpq-dev"
package "libxml2-dev"
package "python2.7"
package "python2.7-dev"

gem_package "right_aws"


# Create directories
["src", "logs", "conf"].each do |child_dir|
  directory "#{app_root}/#{child_dir}" do
    owner node[:webapp][:user]
    group node[:webapp][:group]
    mode "0755"
    action :create
    recursive true
  end
end


# Install Python virtualenv
python_virtualenv "#{virtualenv}" do
  owner node[:webapp][:user]
  group node[:webapp][:group]
  action :create
  interpreter "#{python_interpreter}"
end

# Clone our application source
git "#{src_dir}" do
  repository "https://github.com/johnewart/simplewebpy_app.git"
  action :sync
  branch 'master'
  user node[:webapp][:user]
end

pip_requirements "webapp" do
  action :run
  pip "#{virtualenv}/bin/pip"
  user node[:webapp][:user]
  group node[:webapp][:group]
  requirements_file "#{src_dir}/requirements.txt"
end

# Generate the config file
template "#{src_dir}/config.py" do
  source "config.py.erb"
  user node[:webapp][:user]
  group node[:webapp][:group]
  mode "0600"
  variables({
    :dbname => node[:webapp][:dbname],
    :dbuser => node[:webapp][:dbuser],
    :dbpass => node[:webapp][:dbpass],
    :dbhost => dbhost
  })
end

# Setup a supervisor entry for the webapp
supervisor_service "webapp" do
  action                  [:enable,:restart]
  autostart               true
  user                    node[:webapp][:user]
  command                 "#{virtual_python} #{src_dir}/server.py #{node[:webapp][:port]}"
  stdout_logfile          "#{app_root}/logs/webapp-stdout.log"
  stdout_logfile_backups  5
  stdout_logfile_maxbytes "50MB"
  stdout_capture_maxbytes "0"
  stderr_logfile          "#{app_root}/logs/webapp-stderr.log"
  stderr_logfile_backups  5
  stderr_logfile_maxbytes "50MB"
  stderr_capture_maxbytes "0"
  directory               src_dir
  environment             environment_hash
end
