require 'puppet/indirector/yaml'

class Puppet::ResourceDefaults::Yaml < Puppet::Indirector::Yaml
  desc "Store resource defaults as yaml."
  def resource_dir(resource_type)
    base = Puppet.run_mode.master? ? Puppet[:yamldir] : Puppet[:clientyamldir]
    File.join(base, self.class.indirection_name.to_s, resource_type)
  end

  def destroy(request)
    old_file = path(request.key)
    if File.exists? old_file
      destroyed_file = old_file + '.destroyed'
      if File.exists? destroyed_file
        Puppet.info("Destroying previously destroyed file #{destroyed_file}")
      end
      FileUtils.mv(old_file, destroyed_file)
    else
      Puppet.notice("Cannot destroy user #{request.key}, file #{old_file} does not exist")
    end
  end
end
