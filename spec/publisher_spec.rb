require 'spec_helper'

describe Sawyer::Publisher do
  it "instantiates a Sawyer::Publisher object" do
    publisher = Sawyer::Publisher.new
    expect(publisher).to be_an_instance_of(Sawyer::Publisher)
  end

  it "sanitizes metric names correctly" do
    publisher = Sawyer::Publisher.new
    plain_dotted_metric_key = 'wu.tang.financial'
    pipe_delimited_metric_key = 'wu.tang.financial|type=c|tags=asset:bonds'
    expect(publisher.sanitized_name(plain_dotted_metric_key)).to eq('wu.tang.financial')
    expect(publisher.sanitized_name(pipe_delimited_metric_key)).to eq('wu.tang.financial')
  end

end
