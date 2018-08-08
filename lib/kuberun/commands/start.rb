# frozen_string_literal: true

require_relative '../command'

module Kuberun
  module Commands
    class Start < Kuberun::Command
      def initialize(deployment_name, options)
        @deployment_name = deployment_name
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
