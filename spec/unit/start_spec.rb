# frozen_string_literal: true

require 'kuberun/commands/start'

RSpec.describe Kuberun::Commands::Start do
  it 'executes `start` command successfully' do
    output = StringIO.new
    deployment_name = nil
    options = {}
    command = Kuberun::Commands::Start.new(deployment_name, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
