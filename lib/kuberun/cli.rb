# frozen_string_literal: true

require 'thor'

module Kuberun
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    class_option :'certificate-authority', type: :string, default: '', desc: 'See kubectl options'
    class_option :'client-certificate', type: :string, default: '', desc: 'See kubectl options'
    class_option :'client-key', type: :string, default: '', desc: 'See kubectl options'
    class_option :'cluster', type: :string, default: '', desc: 'See kubectl options'
    class_option :'context', type: :string, default: '', desc: 'See kubectl options'
    class_option :'insecure-skip-tls-verify', type: :string, default: '', desc: 'See kubectl options'
    class_option :'kubeconfig', type: :string, default: '', desc: 'See kubectl options'
    class_option :'namespace', type: :string, default: '', desc: 'See kubectl options', aliases: :'-n'
    class_option :'token', type: :string, default: '', desc: 'See kubectl options'
    class_option :'v', type: :numeric, default: 0, desc: 'Log level, also passed to kubectl'

    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'kuberun version'
    def version
      require_relative 'version'
      puts "v#{Kuberun::VERSION}"
    end
    map %w(--version -v) => :version

    desc 'start DEPLOYMENT-NAME', 'Starts pod for command'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def start(deployment_name)
      if options[:help]
        invoke :help, ['start']
      else
        require_relative 'commands/start'
        Kuberun::Commands::Start.new(deployment_name, options).execute
      end
    end
  end
end
