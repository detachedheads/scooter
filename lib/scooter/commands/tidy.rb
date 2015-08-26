require 'scooter/command'

module Scooter
  module Commands
    class Tidy < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")

        # Build the list of files
        files = options['dir'].nil? ? [options['file']]: Dir.glob("#{options['dir']}/*.json*")

        # Process each of the files
        files.each do |f|
          ext = File.extname(f).delete('.')

          Scooter.ui.info("Tidying configuration: #{f}")

          begin
            # Load the job configuration
            config = JSON.parse(IO.read(f))

            # Create a local app object
            app = Marathon::App.new(config)

            # Write out the app
            app.write_to_file(f)

          rescue Exception => e
            Scooter.ui.warning("Error parsing #{f}.   #{e}")
            next
          end
        end

        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
