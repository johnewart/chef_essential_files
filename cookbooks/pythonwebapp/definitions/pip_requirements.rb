##
# Models a pip requirements.txt file
#

define :pip_requirements , :action => :skip do
    name = params[:name]
    requirements_file = params[:requirements_file]
    pip = params[:pip]
    user = params[:user]
    group = params[:group]

    if params[:action] == :run
      script "pip_install_#{name}" do
        interpreter "bash"
        user "#{user}"
        group "#{group}"
        code <<-EOH
        #{pip} install -r #{requirements_file}
        EOH
        only_if { File.exists?("#{requirements_file}") and File.exists?("#{pip}") }
      end
   end
end
