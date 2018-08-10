RSpec.describe "`kuberun run_pod` command", type: :cli do
  it "executes `kuberun help run_pod` command successfully" do
    output = `kuberun help run_pod`
    expected_output = <<-OUT
Usage:
  kuberun run_pod DEPLOYMENT_NAME

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
