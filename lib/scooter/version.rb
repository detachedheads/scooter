require 'json'

# encoding: utf-8
module Scooter
  # This defines the version of the gem
  module Version
    MAJOR = 0
    MINOR = 1
    PATCH = 2

    STRING = [MAJOR, MINOR, PATCH].compact.join('.')

    NAME   = 'Scooter'
    BANNER = "#{NAME} v%s"

    module_function

    def version
      format(BANNER, STRING)
    end

    def json_version
      {
        'version' => STRING
      }.to_json
    end
  end
end
