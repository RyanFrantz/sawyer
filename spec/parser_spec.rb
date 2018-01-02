require 'spec_helper'

describe Sawyer::Parser, "#new" do
  before(:each) do
    @logfile     = "#{File.dirname(__FILE__)}/fixtures/files/client.log"
    @offset_file = "/tmp/#{File.basename(@logfile)}.offset"
  end

  it "instantiates a Sawyer::Parser object" do
    parser = Sawyer::Parser.new(@logfile, @offset_file)
    expect(parser).to be_an_instance_of(Sawyer::Parser)
    expect(parser.logfile).to equal(@logfile)
    expect(parser.offset_file).to equal(@offset_file)
  end

  it "parses lines correctly" do
    File.delete(@offset_file) if File.exist?(@offset_file)
    parser = Sawyer::Parser.new(@logfile, @offset_file)
    info_metric = 'sawyer.info'
    warn_metric = 'sawyer.warn'
    parser.regexes = {
      Regexp.new('INFO:') => info_metric,
      Regexp.new('WARN:') => warn_metric
    }
    parser.parse
    expect(parser.metrics[info_metric]).to equal(35)
    expect(parser.metrics[warn_metric]).to equal(12)
  end

end
