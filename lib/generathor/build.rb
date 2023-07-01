# frozen_string_literal: true

class Generathor::Build

  def initialize(config)
    @config = config

    $generathor_in_build = true
  end
  
  def build
    remove_bin_files
    create_bin_files
    add_zsh_source
  end
  
  private
  
  def remove_bin_files
    FileUtils.rm_rf("#{@config.bin_path}/.", secure: true)
  end
  
  def create_bin_files
    File.write(mod.bin_path, mod.bin_stmt)
    FileUtils.chmod(0755, mod.bin_path)

    load mod.bin_path
    
    File.write(
      mod.zsh_path,
      mod.zsh_stmt
    )
  end

  def add_zsh_source
    source = "source #{mod.zsh_path}"
    
    return if File.open(@config.zshrc_path)
                  .each_line.any? { |line| line.include?(source) }
    
    File.write(@config.zshrc_path, "\n", mode: 'a')
    File.write(@config.zshrc_path, source, mode: 'a')
  end

  def mod 
    @mod ||= begin
      mod = configured_module

      Generathor::Build::Module.new(
        module_name: File.basename(@config.command_path, ".*" ),
        module_config: mod["config"],
        commands_config: mod["commands"],
        build_config: @config
      )
    end
  end

  def configured_module
    mod = JSON.parse(File.read(@config.command_path))
    config_path = @config.command_path.gsub(/\.json$/, ".config")

    return mod unless File.exist?(config_path)

    config = JSON.parse(File.read(config_path))

    mod["config"].merge!(config)

    mod
  end
end

require_relative './build/config'
require_relative './build/module'
require_relative './build/node'
require_relative './build/namespace'
require_relative './build/command'