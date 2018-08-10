# frozen_string_literal: true

require_relative '../command'

module Kuberun
  module Commands
    class RunPod < Kuberun::Command
      NEW_POD = 'Start new one'

      def initialize(deployment_name, options)
        @deployment_name = deployment_name
        @options = options
        super(options)
      end

      def execute(input: $stdin, output: $stdout)
        output.puts(Kuberun::Pastel.yellow('Checking access to needed commands...'))
        Kuberun::Kubectl.auth_check('create', resource: 'pods')
        Kuberun::Kubectl.auth_check('exec', resource: 'pods')
        output.puts(Kuberun::Pastel.green('You have all permissions needed.'))

        output.puts(Kuberun::Pastel.yellow('Searching for existing pods'))
        existing_pods = Kuberun::Kubectl.get(resource: 'pods', options: "-l kuberun-provisioned=true,kuberun-source=#{@deployment_name}")
        if existing_pods['items'].size > 0
          select = existing_pods['items'].map { |item| item.dig('metadata', 'name') }
          select << NEW_POD

          selection = prompt.select('I found some already running pods. Do you want to use one?', select)

          if selection == NEW_POD
            create_pod_from_deployment(output)
          else
            @generated_pod_name = selection
          end
        else
          create_pod_from_deployment(output)
        end

        execute_command(input, output)

        unless prompt.no?('Should I delete pod?')
          Kuberun::Kubectl.delete(resource: 'pod', resource_name: generated_pod_name)
        end

        output.puts(Kuberun::Pastel.green('Done!'))
      end

      private

      def create_pod_from_deployment(output)
        deployment = Kuberun::Kubectl.get(resource: 'deployment', resource_name: @deployment_name, options: '--export')
        pod_template = deployment['spec']['template']
        prepare_pod_template(pod_template)

        Kuberun::Kubectl.create(configuration: pod_template)
        wait_while do
          pod = Kuberun::Kubectl.get(resource: 'pod', resource_name: generated_pod_name)
          pod.dig('status', 'phase') == 'Running'
        end

        output.puts(Kuberun::Pastel.green('Pod is running!'))
      end

      def prepare_pod_template(pod_template)
        pod_template['apiVersion'] = 'v1'
        pod_template['kind'] = 'Pod'
        pod_template['metadata']['name'] = generated_pod_name

        pod_template['metadata']['labels'] = {
          'kuberun' => Kuberun::VERSION.to_s,
          'kuberun-provisioned' => 'true',
          'kuberun-source' => @deployment_name,
        }

        pod_template['spec']['containers'][0].delete('livenessProbe')
        pod_template['spec']['containers'][0].delete('readinessProbe')
        pod_template['spec'].delete('affinity')
      end

      def wait_while
        loop do
          begin
            status = yield
            raise 'Not ok' unless status
            break
          rescue
            sleep(1)
          end
        end
      end

      def generated_pod_name
        @generated_pod_name ||= "kuberun-#{@deployment_name}-#{Time.now.to_i}"
      end

      def execute_command(_input, output)
        output.puts(Kuberun::Pastel.green('Executing command'))

        Kuberun::Kubectl.exec(pod: generated_pod_name, command: '-it /bin/sh')

        output.puts(Kuberun::Pastel.green('Kubectl exec exited'))
      end

      def prompt
        TTY::Prompt.new
      end
    end
  end
end
