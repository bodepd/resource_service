require 'puppet'
require 'puppet/indirector'

class Puppet::ResourceDefaults
  extend Puppet::Indirector
  indirects :resource_defaults, :terminus_class => :yaml

  attr_reader :name, :params

  def initialize(type, params)
    @name = type
    @params = params[:parameters]
  end

  def to_pson
    "#{name}:#{params.to_pson}"
  end
end
