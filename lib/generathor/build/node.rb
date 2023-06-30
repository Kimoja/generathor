# frozen_string_literal: true

class Generathor::Build::Node
  attr_reader :command_name, :parent, :config, :build_config
  
  def initialize(command_name:, parent:, config:, build_config:)
    @command_name = command_name
    @parent = parent
    @config = config
    @build_config = build_config

    @config["command_path"] = command_path
  end

  def root
    @root ||= branch[0]
  end

  def branch
    @branch ||= (parent.nil? ? [] : parent.branch.dup) << self
  end

  def command_path
    @command_path ||= "#{parent.nil? ? "" : "#{parent.command_path} "}#{command_name}"
  end

  def class_name
   @class_name ||= classify(command_name)
  end

  def class_path
    @class_path ||= begin
      return "::#{build_config.lib_namespace}" if parent.nil?

      klass = "#{parent.class_path}::#{class_name}"

      Object.const_defined?(klass) ? klass : parent.class_path
    end
  end

  def build_class_path
    @build_class_path ||= "#{parent.nil? ? "" : parent.build_class_path}::#{class_name}"
  end

  def arguments
    @arguments ||= 
      (parent.nil? ? [] : parent.arguments.dup).push(*(config["arguments"] || [])) 
  end

  def options
    @options ||= 
      (parent.nil? ? {} : parent.options.dup).merge(config["options"] || {}) 
  end

  ### HELPERS ###

  def classify(str)
    str.split(/_|-/).map { |str| "#{str[0].upcase}#{str[1..]}" }.join
  end
end