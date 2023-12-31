# frozen_string_literal: true

class Generathor::Build::Module

  def initialize(
    module_config:,
    commands_config:,
    build_config:
  )
    @module_config = module_config
    @commands_config = commands_config
    @build_config = build_config

    @command_name = @build_config.command_name
  end

  def bin_stmt
    namespace_stmt = namespace.stmt

    relative = 
      Pathname.new(@build_config.lib_path)
              .relative_path_from(Pathname.new(@build_config.bin_path))

    <<~RUBY
      #!/usr/bin/env ruby
      require 'thor'
      require_relative '#{relative}'

      #{namespace_stmt}
    RUBY
  end

  def zsh_stmt
    <<~BASH
      #{zsh_cmd_stmt}
      #{zsh_autocompletion_stmt}
      #{zsh_aliases_stmt}
    BASH
  end


  def bin_path
    "#{@build_config.bin_path}/#{@command_name}"
  end

  def zsh_path
    "#{@build_config.bin_path}/#{@command_name}.zsh"
  end

  private

  def namespace
    @namespace ||= Generathor::Build::Namespace.new(
      command_name: @command_name,
      parent: nil,
      config: @module_config.merge("lib_path" => @build_config.lib_path),
      commands_config: @commands_config,
      build_config: @build_config
    )
  end

  def zsh_cmd_stmt
    #BUNDLE_GEMFILE=./toolbox/Gemfile
    toolbox_path = File.expand_path("./")
    cmd_call = "BUNDLE_GEMFILE=#{toolbox_path}/Gemfile " \
               "#{toolbox_path}/bin/#{@command_name} \"$@\"" 
    
    <<~BASH
      #{@command_name}() {
        if #{zsh_proxy_command_condition}; then
          echo "Evaluation of command: \"#{@command_name} $@\""
          local cmd=$(#{cmd_call})
          eval $cmd
        else
          #{cmd_call}
        fi
      }
      export "#{@command_name}"
    BASH
  end

  def zsh_proxy_command_condition
    regs = []

    each_commands do |command|
      if command.is_a?(Generathor::Build::Command) && 
         command.command_class.proxy_command?
        regs << "^#{command.command_path.gsub(/^[^\s+]+\s+/, "").gsub(/\s+/, '\\s+')}\\s*"
      end
    end

    reg = regs * "|"

    reg.empty? ? "false" : "echo \"$@\" | grep -Eq '#{reg}'"
  end

  def zsh_autocompletion_stmt
    Thor::ZshCompletion::Generator.new(
      Object.const_get(namespace.class_name), 
      @command_name
    ).generate
  end

  def zsh_aliases_stmt
    aliases = []

    each_commands do |command|
      next unless command.config["zsh_alias"]
      
      aliases << "alias #{command.config["zsh_alias"]}=" \
                 "\"#{command.command_path}\""
    end

    aliases.compact * "\n"
  end

  ### HELPERS ###

  def each_commands(commands = [namespace])
    commands.each do |command|
      yield(command)

      if command.is_a?(Generathor::Build::Namespace)
        each_commands(command.commands) do |sub_command|
          yield(sub_command)
        end
      end
    end
  end
end
