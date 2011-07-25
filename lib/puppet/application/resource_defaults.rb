require 'puppet/application'
require 'puppet/resource_defaults'
# resource service application for 2.6 compatibility
class Puppet::Application::Resource_defaults < Puppet::Application
  should_parse_config
  # TODO : set up logging
  option('--parameters HASH', '-p', '--params')

  def run_command
    raise 'must specify action' if command_line.args.length < 1
    case action = command_line.args.shift
    when 'find'
      find
    when 'save'
      save
    when 'destroy'
      destroy
    else
      raise Puppet::Error, "Unknown action: #{action} for resource service"
    end
  end

  def find
    puts Puppet::ResourceDefaults.find(verify_type).to_pson
  end

  def destroy
    puts Puppet::ResourceDefaults.destroy(verify_type).to_pson
  end

  def save
    # assumes that params are passed to the command line
    # as a string in pson format (json)
    resource_type = verify_type
    if options[:parameters]
      options[:parameters] = PSON.parse(options[:parameters])
    end
    resource = Puppet::ResourceDefaults.new(resource_type.to_sym, :parameters => options[:parameters])
    puts resource.save.to_pson
  end

  def verify_type
    raise(Puppet::Error, "Requires 1 command line options: resource_type") unless command_line.args.size == 1
    resource_type = command_line.args.shift
    resource_type.downcase
  end

  def setup
    Puppet::ResourceDefaults.indirection.terminus_class = 'yaml'
  end

end
