Puppet::Face.define(:resource_service, '0.0.1') do
  summary 'command line wrapper for resouce indirection'

  description <<-EOT
    The resource service is meant as a way to be able to
    store resources in a central db for future usage.
    The only currently support backend is YAML.
    This is likely to change for scalability needs.
  EOT
  # TODO - reset all of the terminuses
  # I am a little concerned about the implications of putting this here
  action(:save) do
    option '--params=, -p=, --parameters=' do
      summary 'pass in parameters as json'
    end
    when_invoked do |resource_type, resource_title, options|
      if options[:params]
        options[:params] = PSON.parse(options[:parameters])
      end
      Puppet::Face[:resource, :current].save("#{resource_type}/#{resource_title}", options)
    end
  end
  action(:find) do
    when_invoked do |resource_type, resource_title, options|
      Puppet::Face[:resource, :current].find("#{resource_type}/#{resource_title}", options)
    end
  end
  action(:destroy) do
    when_invoked do |resource_type, resource_name, options|
      Puppet::Face[:resource, :current].destroy("#{resource_type}/#{resource_name}", options)
    end
  end
  action(:search) do
    when_invoked do |resource_type, options|
      # convert the string into a hash
      # what if it just took a json has on the command line
      Puppet::Face[:resource, :current].search(resource_type, options)
    end
  end
end
