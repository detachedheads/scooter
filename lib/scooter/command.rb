module Scooter
  class Command
    attr_reader :global_options, :options

    def initialize(global_options, options)
      @global_options, @options = global_options, options
    end

    def run
      fail Scooter::Exception, 'Base command has no implementation of `run`'
    end

    def name
      self.class.name.split('::').last.downcase
    end

    private

    #
    # Class Methods
    #
  end

  # Create the commands namespace
  module Commands; end
end
