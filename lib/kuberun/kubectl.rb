# frozen_string_literal: true

require 'open3'
require 'pty'
require 'kuberun/kubectl/exec'

##
# Handles running kubectl
class Kubectl
  CAT_MULTILINE = 'EOFCONFIG'

  KUBECTL_OPTIONS = {
    'certificate-authority': {},
    'client-certificate': {},
    'client-key': {},
    'cluster': {},
    'context': {},
    'insecure-skip-tls-verify': {},
    'kubeconfig': {},
    'namespace': { aliases: :'-n' },
    'token': {},
    'v': { type: :numeric, default: 0, desc: 'Log level passed to kubectl' },
  }.freeze
  SCRIPT_OPTIONS = {
    'cluster-command': { type: 'string', default: '/bin/bash', desc: 'Command to run on cluster' },
    'use-first-pod': { type: 'boolean', default: false, desc: 'Should first existing pod be used automatically?' },
    'cleanup-pod': { type: 'boolean', default: false, desc: 'Should pod be removed after finishing?' },
    'perform-auth-check': { type: 'boolean', default: true, desc: 'Should auth check be performed?' },
    'pty': { type: 'boolean', default: true, desc: 'Should PTY be used?' },
  }.freeze
  OPTIONS = KUBECTL_OPTIONS.merge(SCRIPT_OPTIONS).freeze

  def load_options(options)
    self.options = options
    self.kubectl_options = parsed_options(options)
  end

  def auth_check(verb, resource:, resource_name: nil)
    cmd.run(kubectl_base_command("auth can-i #{verb}", resource: resource, resource_name: resource_name))
  end

  def get(resource:, resource_name: nil, options: nil)
    options = "#{options} --output=json"
    parsed_json do
      cmd.run(kubectl_base_command('get', resource: resource, resource_name: resource_name, options: options)).out
    end
  end

  def create(configuration:, options: nil)
    cmd.run(kubectl_base_input_command('create', configuration: configuration, options: options))
  end

  def exec(pod, options = {})
    Kubectl::Exec.new(self).exec(pod, options)
  end

  def delete(resource:, resource_name:)
    cmd.run(kubectl_base_command('delete', resource: resource, resource_name: resource_name))
  end

  def kubectl_base_command(verb, resource:, resource_name: nil, options: nil)
    base = "#{kubectl} #{options} #{verb} #{resource}"
    base = "#{base}/#{resource_name}" if resource_name
    base
  end

  private

  attr_accessor :kubectl_options, :options

  def cmd(tty_options = {})
    tty_options[:printer] = :progress unless options['debug']
    TTY::Command.new(**tty_options)
  end

  def kubectl_base_input_command(verb, configuration:, options:)
    "cat << '#{CAT_MULTILINE}' | #{kubectl} #{options} #{verb} -f - 2>&1\n#{configuration.to_json}\n#{CAT_MULTILINE}"
  end

  def kubectl
    "kubectl #{kubectl_options}"
  end

  def parsed_options(options)
    options.each_with_object([]) do |(option_name, option_value), arr|
      next if !KUBECTL_OPTIONS.keys.map(&:to_s).include?(option_name) || option_value == ''

      arr << "--#{option_name}=#{option_value}"
    end.join(' ')
  end

  def parsed_json
    JSON.parse(yield)
  end
end
