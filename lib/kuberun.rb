# frozen_string_literal: true

require 'kuberun/version'

require 'pastel'
require 'tty-command'
require 'tty-prompt'

require 'kuberun/kubectl'
require 'json'

module Kuberun
  Kubectl = ::Kubectl.new
  Pastel = ::Pastel.new
  # Your code goes here...
end
