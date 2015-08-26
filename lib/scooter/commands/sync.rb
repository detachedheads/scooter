require 'scooter/command'
require 'json'

module Scooter
  module Commands
    class Sync < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")

        # Build the list of files

        files = options['dir'].nil? ? [options['file']]: Dir.glob("#{options['dir']}/*.json*")

        # Process each of the files based on file extension
        files.each do |f|
          ext = File.extname(f).delete('.')

          # Load the job configuration
          begin
            config = JSON.parse(IO.read(f))
          rescue Exception => e
            Scooter.ui.warning("Error parsing #{f}.   #{e}")
            next
          end

          app_id = config['id']

          case ext
          when 'json'
            begin
              # Attempt to get the app from the server
              app = ::Marathon::App.get(app_id)
              #### TODO:  Need a way to compare the config from disk to config from marathon to see if an udpate is required
              Scooter.ui.info("Updating job '#{app_id}'...")
              app.change!(config, global_options['force'])
            rescue ::Marathon::Error::NotFoundError => e
              Scooter.ui.info("Creating new job '#{app_id}'...")
              # If the app isnt found, this is a new app so create the app
              ::Marathon::App.create(config)
            end
          when 'delete'
            begin
              # Attempt to get the app from the server
              ::Marathon::App.get(app_id)
              Scooter.ui.info("Removing job '#{app_id}'...")
              ::Marathon::App.delete(app_id)
            rescue ::Marathon::Error::NotFoundError => e
              # This is a NO-OP
            end
          when 'suspend'
            begin
              # Attempt to get the app from the server
              app = ::Marathon::App.get(app_id)

              # Do nothing if instances is already zero
              next if app.instances == 0

              Scooter.ui.info("Suspending job '#{app_id}'...")

              app.suspend!(global_options['force'])
            rescue ::Marathon::Error::NotFoundError => e
              # This is a NO-OP
            end
          else
            Scooter.ui.warning("Unknown file extension for #{f}.  Ignorning file.")
          end
        end

        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
