require 'rbconfig'
require 'colorize'
require 'time'

module Scooter
  class UI
    attr_reader :stdout
    attr_reader :stderr
    attr_reader :stdin
    attr_reader :options

    def initialize(stdout, stderr, stdin, options = {})
      @stdout, @stderr, @stdin, @options = stdout, stderr, stdin, options

      # Flush output immediately
      stdout.sync = true
      stderr.sync = true
    end

    def announce(message)
      out("#{color(message, :green, :bold)} ")
    end

    def color(string, color = :light_green, style = :default)
      if color?
        string.colorize(color: color, mode: style)
      else
        string
      end
    end

    def err(message)
      stderr.puts("#{message}") unless @options[:quiet]
    end

    def error(message)
      err("#{color('[ERROR]', :red, :bold)} #{message}")
    end

    def exit(code)
      Kernel.exit!(code)
    end

    def fatal(message)
      err("#{color('[FATAL]', :red, :bold)} #{message}")
    end

    def info(message='',color = :light_green)
      out(color(message,color))
    end

    def out(message='')
      stdout.puts("#{message}") unless @options[:quiet]
    end

    def verbose(message)
      out(color(message)) if @options[:verbose]
    end

    def warn(message)
      err("#{color('[WARNING]', :yellow, :bold)} #{message}")
    end

    private

    def color?
      @options[:color] && stdout.tty? && os != :windows
    end

    def os
      @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          :other
        end
      )
    end
  end
end
