require 'spec_helper'

describe 'An example parser' do
  let(:runner) {Sawyer::Runner.new}
  before(:each) do
    @logfile     = "#{File.dirname(__FILE__)}/fixtures/files/client.log"
    @offset_file = "/tmp/#{File.basename(@logfile)}.offset"
    argv = ['exceptions_spec.rb'] # ARGV[0] is program name.
    argv << %w(--parser example_parser)
    argv << ["--log-file", @logfile]
    argv << ["--offset-file", @offset_file]
    argv << ["--config-file", "sawyer.yml.example"]
    argv.flatten!
    stub_const('ARGV', argv)
  end

  context 'defined via the config' do
    it "instantiates a Sawyer::Parser::ExampleParser object" do
      puts runner.inspect
      expect(runner.parser).to be_an_instance_of(Sawyer::Parser::ExampleParser)
      expect(runner.parser.logfile).to eq(@logfile)
      expect(runner.parser.offset_file).to eq(@offset_file)
    end
  end

end
