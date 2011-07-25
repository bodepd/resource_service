require 'puppet/application'
require 'puppet/resource'
# resource service application for 2.6 compatibility
class Puppet::Application::Resource_service < Puppet::Application
  should_parse_config
  # TODO : set up logging
  option('--parameters HASH', '-p', '--params')
  option('--filters HASH')

  def run_command
    raise 'must specify action' if command_line.args.length < 1
    case action = command_line.args.shift
    when 'find'
      find
    when 'save'
      save
    when 'destroy'
      destroy
    when 'search'
      search
    else
      raise Puppet::Error, "Unknown action: #{action} for resource service"
    end
  end

  def find
    puts Puppet::Resource.find(create_resource_ref).to_pson
  end

  def destroy
    puts Puppet::Resource.destroy(create_resource_ref).to_pson
  end

  def save
    # assumes that params are passed to the command line
    # as a string in pson format (json)
    raise(Puppet::Error, "Save requires 2 command line options: type, title") unless command_line.args.size == 2
    if options[:parameters]
      options[:parameters] = PSON.parse(options[:parameters])
    end
    resource_type = command_line.args.shift
    resource_title = command_line.args.shift
    resource = Puppet::Resource.new(resource_type.to_sym, resource_title, :parameters => options[:parameters])
    puts resource.save.to_pson
  end

  def search
    raise(Puppet::Error, "Search requires 1 command line options: type") unless command_line.args.size == 1
    if options[:filters]
      options[:filters] = PSON.parse(options[:filters])
    end
    resource_type = command_line.args.shift
    puts Puppet::Resource.search(resource_type, options).to_pson
  end

  def create_resource_ref
    raise(Puppet::Error, "Requires 2 command line options: type, title") unless command_line.args.size == 2
    resource_type = command_line.args.shift
    resource_title = command_line.args.shift
    "#{resource_type.capitalize}/#{resource_title}"
  end

  def setup
    Puppet::Resource.indirection.terminus_class = 'yaml'
  end

end
