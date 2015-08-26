# encoding: utf-8
require 'gli'
require 'scooter'

module Scooter
  # The GLI is the primary entry point into the app
  class GLI
    include ::GLI::App

    APP_ID_REGEX = /^[a-zA-z0-9\.\-\/]+$/

    def initialize
      program_desc 'Opinionated synchronization of Marathon jobs from JSON files.'
      version Scooter::Version::STRING.dup

      # Global Accepts

      accept(Fixnum) do |string|
        string.to_i
      end

      # Global Options

      desc 'Enable colorized output'
      switch 'color', default_value: ENV['SCOOTER_COLOR'] || true

      desc 'Marathon Host'
      flag 'marathon', default_value: ENV['SCOOTER_MARATHON_HOST'] || 'http://localhost:8080'

      desc 'Marathon HTTP User'
      flag 'user', default_value: ENV['SCOOTER_MARATHON_USER'] || nil

      desc 'Marathon HTTP Password'
      flag 'pass', default_value: ENV['SCOOTER_MARATHON_PASS'] || nil

      desc 'HTTP Proxy Host'
      flag 'proxy-host', default_value: ENV['SCOOTER_MARATHON_PROXY_HOST'] || nil

      desc 'HTTP Proxy Port'
      flag 'proxy-port', default_value: ENV['SCOOTER_MARATHON_PROXY_PORT'] || nil

      desc 'HTTP Proxy User'
      flag 'proxy-user', default_value: ENV['SCOOTER_MARATHON_PROXY_USER'] || nil

      desc 'HTTP Proxy Password'
      flag 'proxy-pass', default_value: ENV['SCOOTER_MARATHON_PROXY_PASS'] || nil

      desc 'Enable verbose output'
      switch 'verbose', default_value: ENV['SCOOTER_VERBOSE'] || false

      desc 'Attempt to force the desired operation'
      switch 'force', default_value: false
      
      # Pre command execution

      pre do |global_options, _command, _options, _args|

        config = {}

        # Basic HTTP Information
        config[:username] = global_options[:user]
        config[:password] = global_options[:pass]

        # Basic SSL information
        config[:verify]   = false

        # Basic Proxy information
        config[:http_proxyaddr] = global_options['proxy-host']
        config[:http_proxyport] = global_options['proxy-port']
        config[:http_proxyuser] = global_options['proxy-user']
        config[:http_proxypass] = global_options['proxy-pass']
        
        # Set the Marathon credentials if given
        ::Marathon.options = config 

        # Set the Marathon URL
        ::Marathon.url = global_options[:marathon]

        # Setup the UI for the app -- let it use global_options
        Scooter.ui = Scooter::UI.new($stdout, $stderr, $stdin, global_options)
      end

      # Post command execution

      post do |_global_options, _command, _options, _args|
        # Flush the output streams just in case there is anything left
        $stdout.flush
        $stderr.flush
      end

      # Error handling

      on_error do |e|
        #$stderr.puts e.inspect
        $stderr.puts e.message
        $stderr.puts e.backtrace
        true
      end
      
      # Commands

      desc 'Retrieve the configuration for the given app.'
      command :app do |c|

        c.desc 'Application ID'
        c.flag [:id], required: true, must_match: APP_ID_REGEX

        c.desc 'Application Version'
        c.flag [:version], default: nil, type: Fixnum

        c.desc 'Enable JSON output'
        c.switch [:json], default_value: false

        c.action do |global_options, options, _args|
          Scooter::Commands::App.new(global_options, options).run
        end
      end

      desc 'Remove job configurations from Marathon that do not exist in the given directory.'
      command :clean do |c|
        
        c.desc 'A job configuration directory'
        c.flag [:dir, :directory]

        c.desc 'Perform the actual deletion of the jobs in Marathon'
        c.switch [:delete], default_value: false

        c.action do |global_options, options, _args|

          # Verify the source directory exists
          if options['dir'] && !File.directory?(options['dir'])
            Scooter.ui.error("Directory #{options['dir']} does not exist.  Exiting.")
            Scooter.ui.exit(1)
          end

          Scooter::Commands::Clean.new(global_options, options).run
        end
      end

      desc 'Delete the job configuration from Marathon for the given app.'
      command :delete do |c|

        c.desc 'Application ID'
        c.flag [:id], required: true, must_match: APP_ID_REGEX

        c.desc 'Perform the actual deletion of the jobs in Marathon'
        c.switch [:delete], default_value: false

        c.action do |global_options, options, _args|
          Scooter::Commands::Delete.new(global_options, options).run
        end
      end
      
      desc 'Export the jobs configurations whose name matches the given regex.'
      command :export do |c|

        c.desc 'A job configuration directory'
        c.flag [:dir, :directory]

        c.desc 'Marathon Application Regex. (Note: nil implies `.*`)'
        c.flag [:regex], default_value: /.*/

        c.action do |global_options, options, _args|

          # Verify the target directory exists
          if options['dir'] && !File.directory?(options['dir'])
            Scooter.ui.error("Directory #{options['dir']} does not exist.  Exiting.")
            Scooter.ui.exit(1)
          end

          Scooter::Commands::Export.new(global_options, options).run
        end
      end

      desc 'Retrieve Marathon configuration information for the given credentials.'
      command :info do |c|
        c.action do |global_options, options, _args|
          Scooter::Commands::Info.new(global_options, options).run
        end
      end

      desc 'Scale the number of instances of a given app.'
      command :scale do |c|

        c.desc 'Application ID'
        c.flag [:id], required: true, must_match: APP_ID_REGEX

        c.desc 'Specify the number of instances of the application'
        c.flag [:instances], required: true, type: Fixnum

        c.action do |global_options, options, _args|
          Scooter::Commands::Scale.new(global_options, options).run
        end
      end

      desc 'Synchronize the given job configuration(s) with Marathon.'
      command :sync do |c|

        c.desc 'A job configuration directory'
        c.flag [:dir, :directory]

        c.desc 'A job configuration file'
        c.flag [:file]

        c.action do |global_options, options, _args|
          Scooter.ui.warn('Both `dir` and `file` options given.  Ignoring `file`.') if !options['dir'].nil? && !options['file'].nil?
          
          if options['dir'].nil? && options['file'].nil?
            Scooter.ui.error('Either `dir` and `file` must be used.  Exiting.')
            Scooter.ui.exit(1)
          end

          # Verify the file exists
          if options['file'] && !File.exists?(options['file'])
            Scooter.ui.error("File #{options['file']} does not exist.  Exiting.")
            Scooter.ui.exit(1)
          end

          # Verify the directory exists
          if options['dir'] && !File.directory?(options['dir'])
            Scooter.ui.error("Directory #{options['dir']} does not exist.  Exiting.")
            Scooter.ui.exit(1)
          end

          Scooter::Commands::Sync.new(global_options, options).run
        end
      end

      desc 'Tidy the JSON format for the given job configuration(s).'
      command :tidy do |c|

        c.desc 'A job configuration directory'
        c.flag [:dir, :directory]

        c.desc 'A job configuration file'
        c.flag [:file]

        c.action do |global_options, options, _args|
          Scooter.ui.warn('Both `dir` and `file` options given.  Ignoring `file`.') if !options['dir'].nil? && !options['file'].nil?
          
          if options['dir'].nil? && options['file'].nil?
            Scooter.ui.error('Either `dir` and `file` must be used.  Exiting.')
            Scooter.ui.exit(1)
          end

          # Verify the file exists
          if options['file'] && !File.exists?(options['file'])
            Scooter.ui.error("File #{options['file']} does not exist.  Exiting.")
            Scooter.ui.exit(1)
          end

          # Verify the directory exists
          if options['dir'] && !File.directory?(options['dir'])
            Scooter.ui.error("Directory #{options['dir']} does not exist.  Exiting.")
            Scooter.ui.exit(1)
          end

          Scooter::Commands::Tidy.new(global_options, options).run
        end
      end
    end

    def execute!
      run(ARGV)
    end
  end
end
