# encoding: utf-8

# Third Party
require 'marathon'

# Internal

require 'scooter/command'
require 'scooter/exceptions'
require 'scooter/gli'
require 'scooter/ui'
require 'scooter/version'

# Commands

require 'scooter/commands/app'
require 'scooter/commands/clean'
require 'scooter/commands/delete'
require 'scooter/commands/export'
require 'scooter/commands/info'
require 'scooter/commands/scale'
require 'scooter/commands/sync'
require 'scooter/commands/tidy'

# Extensions
require 'extensions/hash'
require 'extensions/marathon/app'

module Scooter
  class << self
    attr_writer :ui
  end

  class << self
    attr_reader :ui
  end
end
