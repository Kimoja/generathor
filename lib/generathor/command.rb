# frozen_string_literal: true

class Generathor::Command
  class Arguments < Generathor::Struct; end
  class Options < Generathor::Struct; end
  class Config < Generathor::Struct; end

  def self.inherited(subclass)
    subclass.class_eval <<~RUBY 
      class Arguments < #{subclass}::Arguments; end 
      class Options < #{subclass}::Options; end 
      class Config < #{subclass}::Config; end 
    RUBY
  end

  def self.arguments(argument_name, &block)
    apply_method_name = :"_apply_#{argument_name}"
    self::Arguments.define_method(argument_name) do 
      send(apply_method_name, get(argument_name))
    end

    self::Arguments.define_method(apply_method_name, &block)
  end

  def self.options(option_name, &block)
    apply_method_name = :"_apply_#{option_name}"
    self::Option.define_method(option_name) do 
      send(apply_method_name, get(option_name))
    end

    self::Option.define_method(apply_method_name, &block)
  end

  def self.config(config_name, &block)
    apply_method_name = :"_apply_#{config_name}"
    self::Config.define_method(config_name) do 
      send(apply_method_name, get(config_name))
    end

    self::Config.define_method(apply_method_name, &block)
  end

  attr_reader :arguments, :options, :config

  def self.proxy_command?
    false
  end

  def initialize(arguments, options, config)
    @arguments = arguments
    @options = options
    @config = config

    arguments.command = self
    options.command = self
    config.command = self
  end

  def exec
    methods = [
      :"exec_#{config.command_name}_#{config.module_name}",
      :"exec_#{config.command_name}",
      :"exec_#{config.module_name}",
    ].each do |method|
      return send(method) if respond_to?(method)
    end

    raise NotImplementedError
  end
end
