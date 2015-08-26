require 'scooter/command'

module Scooter
  module Commands
    class Scale < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")

        begin
          app = ::Marathon::App.get(options['id'])

          if app.instances != options['instances']
            Scooter.ui.info("Scaling '#{options['id']}' from #{app.instances} to #{options['instances']}...")
            app.scale!(options['instances'], global_options['force'])
          else
            Scooter.ui.info("'#{options['id']}' instances already set to #{options['instances']}.")
          end
          
        rescue ::Marathon::Error::NotFoundError => e
          Scooter.ui.warn(e)
        end
        
        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
