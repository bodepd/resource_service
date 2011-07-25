require 'puppet/face'
Puppet.parse_config
Puppet::Resource.indirection.terminus_class='yaml'
{'dan' => '/bin/bash', 'jeff' => '/bin/bash', 'bob' => '/bin/csh'}.each do |name, shell|
  resource = Puppet::Resource.new(:user, name, :parameters => {:ensure => :present, :shell => shell})
  Puppet::Face[:resource, :current].save(resource)
end
resources = Puppet::Face[:resource, :current].search('user', {:filters => {:shell => '/bin/bash'}})
puts Puppet::Face[:resource, :current].find('user/dan').inspect
puts resources.inspect
