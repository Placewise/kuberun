RSpec.describe "`kuberun start` command", type: :cli do
  it "executes `kuberun help start` command successfully" do
    output = `kuberun help start`
    expected_output = <<-OUT
Usage:
  kuberun start DEPLOYMENT_NAME

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
