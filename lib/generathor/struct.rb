# frozen_string_literal: true

class Generathor::Struct

  attr_reader :source
  attr_accessor :command

  def initialize(source = {})
    @source = source
  end

  def method_missing(key, *args, &_block)
    get(key, args[0])
  end

  protected

  def get(key, default = nil)
    return source[key.to_s] if source.key?(key.to_s) 
    return source[key.to_sym] if source.key?(key.to_sym)

    default
  end
end
