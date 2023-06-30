# frozen_string_literal: true

class Generathor::Build::Config

  attr_reader :commands_glob, :lib_path, :lib_namespace, 
             :bin_path, :zshrc_path, :zsh_sources_path

  def initialize(
    commands_glob:, 
    lib_path:,
    lib_namespace:,
    bin_path:,
    zshrc_path:,
    zsh_sources_path:
  )
    @commands_glob = commands_glob
    @lib_path = lib_path
    @lib_namespace = lib_namespace
    @bin_path = bin_path
    @zshrc_path = zshrc_path
    @zsh_sources_path = zsh_sources_path
  end
end