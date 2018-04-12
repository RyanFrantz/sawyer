require 'spec_helper'

# Here we test a complex example of a config-derived parser whose attributes
# are explicitly defined.
# For a general regexp-to-string parser example, see spec/parser_spec.rb.
describe 'An example parser' do
  let(:runner) {Sawyer::Runner.new}
  before(:each) do
    @logfile     = "#{File.dirname(__FILE__)}/fixtures/files/client.log"
    # Create a unique offset file so we don't get stuck with a previous offset
    # file gumming up the works during lots of manual testing.
    @offset_file = "/tmp/#{File.basename(@logfile)}-#{Time.now.to_i}.offset"
    argv = ['exceptions_spec.rb'] # ARGV[0] is program name.
    argv << %w(--parser chef_client_log)
    argv << ["--log-file", @logfile]
    argv << ["--offset-file", @offset_file]
    argv << ["--config-file", "sawyer.yml.example"]
    argv.flatten!
    stub_const('ARGV', argv)
  end

  context 'defined via the config' do
    it "instantiates a Sawyer::Parser::ChefClientLog object" do
      #puts runner.inspect
      expect(runner.parser).to be_an_instance_of(Sawyer::Parser::ChefClientLog)
      expect(runner.parser.logfile).to eq(@logfile)
      expect(runner.parser.offset_file).to eq(@offset_file)
      runner.parser.parse
      expect(runner.parser.metrics['sawyer.info']['value']).to eq(35)
      expect(runner.parser.metrics['sawyer.info']['type']).to eq('c')
      expect(runner.parser.metrics['sawyer.info']['sample_rate']).to eq('0.1')
      expect(runner.parser.metrics['sawyer.warn']['value']).to eq(12)
      expect(runner.parser.metrics['sawyer.warn']['type']).to eq('c')
      expect(runner.parser.metrics['sawyer.warn']['sample_rate']).to eq('0.3')
    end
  end

end
