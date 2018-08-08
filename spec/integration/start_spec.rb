RSpec.describe "`kuberun start` command", type: :cli do
  it "executes `kuberun help start` command successfully" do
    output = `kuberun help start`
    expected_output = <<-OUT
Usage:
  kuberun start DEPLOYMENT-NAME

Options:
  -h, [--help], [--no-help]                                  # Display usage information
      [--certificate-authority=CERTIFICATE-AUTHORITY]        # See kubectl options
      [--client-certificate=CLIENT-CERTIFICATE]              # See kubectl options
      [--client-key=CLIENT-KEY]                              # See kubectl options
      [--cluster=CLUSTER]                                    # See kubectl options
      [--context=CONTEXT]                                    # See kubectl options
      [--insecure-skip-tls-verify=INSECURE-SKIP-TLS-VERIFY]  # See kubectl options
      [--kubeconfig=KUBECONFIG]                              # See kubectl options
  -n, [--namespace=NAMESPACE]                                # See kubectl options
      [--token=TOKEN]                                        # See kubectl options
      [-v=N]                                                 # Log level, also passed to kubectl
                                                             # Default: 0

Starts pod for command
    OUT

    expect(output).to eq(expected_output)
  end
end
