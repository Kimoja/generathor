# frozen_string_literal: true

class Generathor::Build::Command < Generathor::Build::Node

  attr_reader :command_class_path

  def stmt
    <<~RUBY
      desc("#{command_sig}", "#{config["description"] || ""}")
      method_options(#{options})
      def #{function_sig}
       #{class_path}.new(
          #{class_path}::Arguments.new(#{arguments_stmt}), 
          #{class_path}::Options.new(options), 
          #{class_path}::Config.new(#{config_stmt})
      ).exec
      end
    RUBY
  end

  def command_class
    Object.const_get(class_path)
  end

  private

  def command_sig
    ([command_name] + arguments.map { |arg| arg.sub('?', '') }) * ' '
  end

  def function_sig
    args = arguments.map do |arg|
      next arg.downcase unless arg.include?('?')

      "#{arg.downcase.sub('?', '')} = nil"
    end

    "#{command_name}(#{args * ','})"
  end

  def arguments_stmt
    args = arguments.map do |arg| 
      darg = arg.gsub(/\?|\*/, '').downcase
      "#{darg}: #{darg}"
    end

    args * ", "
  end

  def config_stmt
    "#{parent.build_class_path}.config.dup.merge(#{config})"
  end
end