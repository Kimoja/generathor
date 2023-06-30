# frozen_string_literal: true

class Generathor::Build

  def initialize(config)
    @config = config

    $generathor_in_build = true
  end
  
  def build
    create_zsh_sources_dir
    remove_zsh_sources_files
    remove_bin_files
    create_bin_files
    create_zsh_files
    add_zsh_sources
  end
  
  private

  def create_zsh_sources_dir
    FileUtils.mkdir_p(@config.zsh_sources_path)
  end
  
  def remove_zsh_sources_files
    FileUtils.rm_rf("#{@config.zsh_sources_path}/.", secure: true)
  end

  def remove_bin_files
    FileUtils.rm_rf("#{@config.bin_path}/.", secure: true)
  end
  
  def create_bin_files
    modules.each do |mod|
      File.write(mod.bin_path, mod.bin_stmt)
      FileUtils.chmod(0755, mod.bin_path)
    end
  end

  def create_zsh_files
    modules.each do |mod|
      load mod.bin_path
      
      File.write(
        mod.zsh_path,
        mod.zsh_stmt
      )
    end
  end

  def add_zsh_sources
    sources = modules.map do |mod|
      "source #{mod.zsh_path}"
    end
    
    sources_path = "#{@config.zsh_sources_path}/.sources"
    File.write(sources_path, sources * "\n")

    source = "source #{sources_path}"

    return if File.open(@config.zshrc_path)
                  .each_line.any? { |line| line.include?(source) }
    
    File.write(@config.zshrc_path, "\n", mode: 'a')
    File.write(@config.zshrc_path, source, mode: 'a')
  end

  def modules 
    @modules ||= begin
      Dir[@config.commands_glob].map do |file_path| 
        config = JSON.parse(File.read(file_path))

        commands = config.delete("commands")
        modules = config.delete("modules")

        modules.map do |module_config|
          Generathor::Build::Module.new(
            module_config: {}.merge(config).merge(module_config),
            commands_config: commands,
            build_config: @config
          )
        end
      end.flatten
    end
  end
end

require_relative './build/config'
require_relative './build/module'
require_relative './build/node'
require_relative './build/namespace'
require_relative './build/command'