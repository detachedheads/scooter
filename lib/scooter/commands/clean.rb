require 'scooter/command'

module Scooter
  module Commands
    class Clean < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")

        local_ids  = []
        
        # Build the list of files

        files = Dir.glob("#{options['dir']}/*.json*")

        # Build a list of app ids from the local configuration files
        files.each do |f|
          ext = File.extname(f).delete('.')

          # Load the job configuration
          begin
            config = JSON.parse(IO.read(f))
          rescue Exception => e
            Scooter.ui.warning("Error parsing #{f}.   #{e}")
            next
          end

          # Prefix with a leading slash if missing
          local_ids << (config['id'].start_with?('/') ? config['id'] : "/#{config['id']}")
        end

        # Iterate the apps
        ::Marathon::App.list.each do |app|

          next if local_ids.include? app.id

          # If delete is flagged do the actual delete
          if options['delete']

            # Delete the app
            ::Marathon::App.delete(app.id)

            Scooter.ui.info("Job '#{app.id}' removed.")
          else
            Scooter.ui.info("[DRYRUN] Job '#{app.id}' removed.")
          end
        end
        
        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
