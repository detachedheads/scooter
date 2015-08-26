require 'scooter/command'
require 'colorize'

module Scooter
  module Commands
    class Info < Scooter::Command
      def run
        Scooter.ui.verbose("Executing the `#{name}` command.")
        Scooter.ui.announce('---- Marathon Configuration ----')
        Scooter.ui.out("Name:              #{::Marathon.info['name']}")
        Scooter.ui.out("Checkpoint:        #{::Marathon.info['marathon_config']['checkpoint']}")
        Scooter.ui.out("High Availability: #{::Marathon.info['marathon_config']['ha'].to_s.green}")
        Scooter.ui.out("Version:           #{::Marathon.info['version']}")
        Scooter.ui.out
        
        apps = ::Marathon::App.list
        if apps.length > 0
          Scooter.ui.announce('---- Application Configuration ----')
          ::Marathon::App.list.each do |app|
            # Derive the colors for the various output
            read_only_color = app.read_only ? :red : :light_green
            
            Scooter.ui.out("#{printf('%-25s', app.id)}  I:#{app.instances} C:#{app.cpus} M:#{app.mem} D:#{app.disk} RO:#{Scooter.ui.color(app.read_only.to_s,read_only_color)}")
          end
        else
          Scooter.ui.warn('There are no applications configured.')
        end

        Scooter.ui.verbose("Execution of `#{name}` command has completed.")
      end
    end
  end
end
