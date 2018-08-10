# frozen_string_literal: true

require 'forwardable'

class Kubectl
  ##
  # Handles running kubectl exec
  class Exec
    extend Forwardable

    def_delegators :@kubectl, :kubectl_base_command

    def initialize(kubectl)
      @kubectl = kubectl
    end

    def exec(pod:, command:)
      old_state = `stty -g`

      PTY.spawn("#{kubectl_base_command('exec', resource: pod)} #{command}") do |out, inp, pid|
        pty_process(out, inp, pid, old_state)
      end
    end

    private

    attr_reader :stdin_thread, :stdout_thread

    def prepare_stdin_thread(inp)
      @stdin_thread = Thread.new do
        until inp.closed?
          input = $stdin.getch
          inp.write(input)
          inp.flush
        end
      end
    end

    def prepare_stdout_thread(out)
      @stdout_thread = Thread.new do
        until out.eof?
          $stdout.print(out.readchar)
          $stdout.flush
        end
      rescue Errno::EIO, EOFError
        nil
      end
    end

    def pty_process(out, inp, pid, old_state)
      prepare_stdin_thread(inp)
      prepare_stdout_thread(out)

      stdin_thread.run

      wait_for_process(pid)

      stdout_thread.join
      stdin_thread.kill

      sleep 0.1
    ensure
      cleanup_pty(old_state)
    end

    def wait_for_process(pid)
      Process.waitpid(pid)
    rescue StandardError
      nil # "rescue nil" is there in case process already ended.
    end

    def cleanup_pty(old_stty_state)
      stdout_thread&.kill
      stdin_thread&.kill
      $stdout.puts
      $stdout.flush

      system("stty #{old_stty_state}")
    end
  end
end
