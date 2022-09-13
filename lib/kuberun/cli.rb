# frozen_string_literal: true

require 'thor'

module Kuberun
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    DEFAULT_OPTIONS_FOR_KUBECTL_OPTIONS = { type: :string, default: '', desc: 'See kubectl options' }.freeze
    ::Kubectl::OPTIONS.each do |option_name, hash|
      class_option option_name, DEFAULT_OPTIONS_FOR_KUBECTL_OPTIONS.merge(hash)
    end
    class_option :debug, type: :boolean, default: false, desc: 'Debug logging'

    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'kuberun version'
    def version
      require_relative 'version'
      puts "v#{Kuberun::VERSION}"
    end
    map %w[--version -v] => :version

    desc 'run_pod DEPLOYMENT_NAME', 'Starts pod for command'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def run_pod(deployment_name)
      if options[:help]
        invoke :help, ['run_pod']
      else
        require_relative 'commands/run_pod'
        Kuberun::Commands::RunPod.new(deployment_name, options).execute
      end
    end
  end
end
