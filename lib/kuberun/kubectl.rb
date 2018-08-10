# frozen_string_literal: true

require 'open3'
require 'pty'

class Kubectl
  CAT_MULTILINE = 'EOFCONFIG'
  KUBECTL_OPTIONS = Kuberun::CLI::BASE_KUBECTL_OPTIONS.keys.map(&:to_s)

  def load_options(options)
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

  def exec(pod:, command:)
    old_state = `stty -g`

    PTY.spawn("#{kubectl_base_command('exec', resource: pod)} #{command}") do |o, i, pid|
      t_in = Thread.new do
        until i.closed? do
          input = $stdin.getch
          i.write(input)
          i.flush
        end
      end

      t_out = Thread.new do
        begin
          until o.eof? do
            $stdout.print(o.readchar)
            $stdout.flush
          end
        rescue Errno::EIO, EOFError
          nil
        end
      end

      t_in.run

      Process::waitpid(pid) rescue nil
      # "rescue nil" is there in case process already ended.

      t_out.join
      t_in.kill
      sleep 0.1
    ensure
      t_out&.kill
      t_in&.kill
      $stdout.puts
      $stdout.flush
      system "stty #{ old_state }"
    end
  end

  def delete(resource:, resource_name:)
    cmd.run(kubectl_base_command('delete', resource: resource, resource_name: resource_name))
  end

  private

  attr_accessor :kubectl_options

  def cmd(tty_options = {})
    TTY::Command.new(tty_options)
  end

  def kubectl_base_command(verb, resource:, resource_name: nil, options: nil)
    base = "#{kubectl} #{options} #{verb} #{resource}"
    base = "#{base}/#{resource_name}" if resource_name
    base
  end

  def kubectl_base_input_command(verb, configuration:, options:)
    "cat << '#{CAT_MULTILINE}' | #{kubectl} #{options} #{verb} -f - 2>&1\n#{configuration.to_json}\n#{CAT_MULTILINE}"
  end

  def kubectl
    "kubectl #{kubectl_options}"
  end

  def parsed_options(options)
    options.each_with_object([]) do |(option_name, option_value), arr|
      next if !KUBECTL_OPTIONS.include?(option_name) || option_value == ''

      arr << "--#{option_name}=#{option_value}"
    end.join(' ')
  end

  def parsed_json
    JSON.load(yield)
  end
end
