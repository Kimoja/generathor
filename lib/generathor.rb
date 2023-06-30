# frozen_string_literal: true

require 'thor'
require 'thor/zsh_completion'
require 'pathname'
require 'fileutils'
require 'json'

module Generathor; end

require_relative "./generathor/struct"
require_relative "./generathor/command"
require_relative "./generathor/build"