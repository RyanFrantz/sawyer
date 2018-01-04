require 'spec_helper'

describe 'Exception handling, such as' do
  let(:runner) {Sawyer::Runner.new}
  before(:each) do
    argv = ['exceptions_spec.rb'] # ARGV[0] is program name.
    argv << %w(--parser does_not_matter)
    argv << ["--log-file", "it_does_not_exist.log"]
    argv.flatten!
    stub_const('ARGV', argv)
  end

  context 'when a log file cannot be found' do
    it "raises a Sawyer::LogfileNotFound exception" do
      expect{runner.validate_logfile!}.to raise_error(Sawyer::LogfileNotFound)
    end
  end

  context 'when a parser cannot be found' do
    it "raises a Sawyer::ParserNotFound exception" do
      expect{runner.validate_parser!}.to raise_error(Sawyer::ParserNotFound)
    end
  end

end

