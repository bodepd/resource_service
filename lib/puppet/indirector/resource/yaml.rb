require 'puppet/indirector/yaml'
require 'puppet/resource_defaults'

class Puppet::Resource::Yaml < Puppet::Indirector::Yaml
  desc "Store resource information as flat files, serialized using YAML,
    or deserialize stored YAML nodes."
  def find(request)
    request.options[:merge_defaults] ||= true
    if resource = super(request) and request.options[:merge_defaults]
      # load and merge resource defaults
      resource_split = request.key.split('/')
      defaults = Puppet::ResourceDefaults.find(resource_split[0])
      # merge the resource params over the defaults
      # parameters should not be private
      merged_params = defaults.params.merge(resource.send(:parameters))
      resource = Puppet::Resource.new(resource_split[0].to_sym, resource_split[1], :parameters => merged_params)
    end
  end

  def search(request)
    # get all resources
    resources = Dir.glob(File.join(resource_dir(request.key), '*.yaml')).collect do |file|
      resource = YAML.load_file(file)
    end.select do |resource|
      resource_matches?(resource, request.options[:filters])
    end
  end

  def resource_matches?(resource, opts)
    opts.each do |param, value|
      return false unless resource[param.to_sym] == value
    end
    true
  end

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
