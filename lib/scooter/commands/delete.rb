require 'scooter/command'

module Scooter
  module Commands
    class Delete < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")

        begin

          app = ::Marathon::App.get(options['id'])
          
          # If delete is flagged do the actual delete
          if options['delete']

            # Delete the app
            ::Marathon::App.delete(app.id)

            Scooter.ui.info("Job '#{app.id}' removed.")
          else
            Scooter.ui.info("[DRYRUN] Job '#{app.id}' removed.")
          end
        rescue ::Marathon::Error::NotFoundError => e
          Scooter.ui.warn(e)
        end
        
        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
