require 'open3'

class Kubectl
  class << self
    CAT_MULTILINE = 'EOFCONFIG'

    def apply(config)
      Open3.capture3(kubectl_base_command(config, 'apply'))
    end

    def delete(config)
      Open3.capture3(kubectl_base_command(config, 'delete'))
    end

    def delete_by_name(name, namespace, kind)
      command = "#{kubectl} delete #{kind} -n #{namespace} #{name}"
      Open3.capture3(command)
    end

    private

    def kubectl_base_command(config, action)
      "cat << '#{CAT_MULTILINE}' | #{kubectl} #{action} -f - 2>&1\n#{config}\n#{CAT_MULTILINE}"
    end

    def kubectl
      'kubectl'
    end
  end
end
