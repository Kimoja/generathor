# frozen_string_literal: true

class Generathor::Build::Config

  attr_reader :command_path, :lib_path, :lib_namespace, 
             :bin_path, :zshrc_path

  def initialize(
    command_path:, 
    lib_path:,
    lib_namespace:,
    bin_path:,
    zshrc_path:
  )
    @command_path = command_path
    @lib_path = lib_path
    @lib_namespace = lib_namespace
    @bin_path = bin_path
    @zshrc_path = zshrc_path
  end
end