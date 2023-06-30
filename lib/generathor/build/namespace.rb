# frozen_string_literal: true

class Generathor::Build::Namespace < Generathor::Build::Node

  attr_reader :commands_config
  
  def initialize(command_name:, parent:, config:, commands_config:, build_config:)
    super(command_name:, parent:, config:, build_config:)
    @commands_config = commands_config
  end

  def stmt
    stmts = ["class #{class_name} < Thor"]
    stmts << config_stmt

    commands.each do |sub_command|
      stmts << sub_command.stmt
    end

    stmts << "end"
    
    if parent.nil?
      stmts << <<~RUBY
        unless defined?($generathor_in_build)
          #{class_name}.start
        end
      RUBY
    else
      stmts << <<~RUBY
        desc("#{command_name} SUBCOMMAND", "#{command_name} Commands")
        subcommand("#{command_name}", #{class_name})
      RUBY
    end
    
    stmts * "\n"
  end
  
  def commands
    @commands ||= @commands_config.map do |(sub_command_name, sub_config)|

      sub_config = sub_config.dup
      sub_command_config = sub_config.delete("commands")

      args = { 
        command_name: sub_command_name,
        parent: self,
        config: sub_config,
        build_config: build_config
      }
      
      if sub_command_config
        args[:commands_config] = sub_command_config
        Generathor::Build::Namespace.new(**args)
      else
        Generathor::Build::Command.new(**args)
      end
    end
  end

  private

  def config_stmt
    <<~RUBY
      def self.config
        #{config}.merge(#{parent.nil? ? "{}" : "#{parent.build_class_path}.config"})
      end
    RUBY
  end
end