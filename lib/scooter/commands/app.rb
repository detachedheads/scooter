require 'scooter/command'

module Scooter
  module Commands
    class App < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")

        begin
          if options['version']
            app = ::Marathon::App.version(options['id'], options['name'])
          else
            app = ::Marathon::App.get(options['id'])
          end

          if options['json']
            Scooter.ui.info(app.info_to_json)
          else
            Scooter.ui.info(app.to_pretty_s)
          end
        rescue ::Marathon::Error::NotFoundError => e
          Scooter.ui.warn(e)
        end
        
        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
