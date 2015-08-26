require 'scooter/command'

module Scooter
  module Commands
    class Export < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")
        
        # Convert the argument to a regex
        app_regex = Regexp.new options['regex']
        
        begin
          # Iterate each of the configured apps
          ::Marathon::App.list.each do |app|
            if app.id =~ app_regex

              # Deterine the suffix
              suffix        = '.json'
              action_suffix = ''
              action_suffix += '.suspend' if app.instances == 0
              
              # Determine the destination file
              dest_file         = ::File.join(options['dir'], "#{app.id}#{suffix}")
              action_dest_file  = dest_file + action_suffix

              Scooter.ui.info("Exporting `#{app.id}` to #{action_dest_file}")
              
              # Delete any files that are for this application
              Dir.glob(dest_file + '*').each do |filename|
                # Do not delete the file we are going to write to
                next if filename == action_dest_file

                Scooter.ui.warn("      Removing stale configuration: #{filename}")

                # Delete the file
                File.delete(filename)
              end
              
              # Write the file
              app.write_to_file(action_dest_file)
            else
              Scooter.ui.info("`#{app.id}` excluded by regex.")
            end
          end
        rescue ::Marathon::Error::NotFoundError => e
          Scooter.ui.warn(e)
        end

        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
