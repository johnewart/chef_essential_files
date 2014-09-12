maintainer       "John Ewart"
maintainer_email "john@johnewart.net"
license          "Apache 2.0"
description      "Creates users from a databag search"
long_description "Example user management cookbook, modified from an old users cookbook from Opscode"
version          "1.0.0"

recipe "users::shell_users", "searches users data bag for shell users based on a node's properties and creates users"
recipe "users::ssh_keys", "manage public SSH keys for users"
recipe "users::deploy_keys", "manage SSH private keys for deployment users"

%w{ ubuntu debian redhat centos fedora freebsd}.each do |os|
  supports os
end
