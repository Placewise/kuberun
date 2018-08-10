require 'kuberun/commands/run_pod'

RSpec.describe Kuberun::Commands::RunPod do
  it "executes `run_pod` command successfully" do
    output = StringIO.new
    deployment_name = nil
    options = {}
    command = Kuberun::Commands::RunPod.new(deployment_name, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
