require 'spec_helper'

describe "instances/show.html.erb" do
  before(:each) do
    @instance = assign(:instance, stub_model(Instance,
      :host => "Host",
      :port => "Port",
      :priority => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Host/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Port/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
