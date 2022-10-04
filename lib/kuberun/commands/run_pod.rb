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
        if @options['perform-auth-check']
          output.print(Kuberun::Pastel.yellow('Checking access to needed commands'))
          Kuberun::Kubectl.auth_check('create', resource: 'pods')
          Kuberun::Kubectl.auth_check('exec', resource: 'pods')

          output.puts
          output.puts(Kuberun::Pastel.green('You have all permissions needed'))
        end

        output.print(Kuberun::Pastel.yellow('Searching for existing pods'))
        existing_pods = Kuberun::Kubectl.get(resource: 'pods', options: "-l kuberun-provisioned=true,kuberun-source=#{@deployment_name}")
        if existing_pods['items'].size > 0
          if @options['use-first-pod']
            @generated_pod_name = existing_pods['items'].first.dig('metadata', 'name')
          else
            select = existing_pods['items'].map { |item| item.dig('metadata', 'name') }
            select << NEW_POD

            selection = prompt.select('I found some already running pods. Do you want to use one?', select)

            if selection == NEW_POD
              create_pod_from_deployment(output)
            else
              @generated_pod_name = selection
            end
          end
        else
          create_pod_from_deployment(output)
        end

        execute_command(input, output)

        if @options['cleanup-pod'] || prompt.yes?(Kuberun::Pastel.yellow('Should I delete pod?'))
          Kuberun::Kubectl.delete(resource: 'pod', resource_name: generated_pod_name)
          Kuberun::Pastel.green("Pod #{generated_pod_name} has been deleted!")
        end

        output.puts
      end

      private

      def create_pod_from_deployment(output)
        deployment = Kuberun::Kubectl.get(resource: 'deployment', resource_name: @deployment_name, options: '')
        pod_template = deployment['spec']['template']
        prepare_pod_template(pod_template)

        Kuberun::Kubectl.create(configuration: pod_template)
        wait_while do
          pod = Kuberun::Kubectl.get(resource: 'pod', resource_name: generated_pod_name)
          pod.dig('status', 'phase') == 'Running'
        end

        output.puts
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

        pod_template['spec']['containers'].each do |container|
          container.delete('livenessProbe')
          container.delete('readinessProbe')
          container['command'] = %w[/bin/sh -c --]
          container['args'] = ['while true; do sleep 1000; done']
        end

        pod_template['spec'].delete('priority')
        pod_template['spec']['priorityClassName'] = 'system-cluster-critical'
        pod_template['spec']['affinity'] = {
          'podAntiAffinity' => {
            'requiredDuringSchedulingIgnoredDuringExecution' => [
              {
                'labelSelector' => {
                  'matchExpressions' => [
                    {
                      'key' => 'spot',
                      'operator' => 'In',
                      'values' => ['true']
                    }
                  ]
                },
                'topologyKey' => 'kubernetes.io/hostname',
              }
            ]
          }
        }
        pod_template['spec']['terminationGracePeriodSeconds'] = 0
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

        Kuberun::Kubectl.exec(generated_pod_name, @options)

        output.puts(Kuberun::Pastel.green('Kubectl exec exited'))
      end

      def prompt
        TTY::Prompt.new
      end
    end
  end
end
