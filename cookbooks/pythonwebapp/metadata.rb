maintainer       "John Ewart"
maintainer_email "john@johnewart.net"
license          "Apache 2.0"
description      "Generic Python Webapp cookbook"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0"

depends 		 "python"
depends 		 "git"
depends			 "aws"
depends 		 "nginx"
depends      "ssh_known_hosts"
depends      "database"
depends      "supervisor"

%w{ debian }.each do |os|
  supports os
end
