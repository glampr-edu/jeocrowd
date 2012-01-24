require 'spec_helper'

describe "instances/new.html.erb" do
  before(:each) do
    assign(:instance, stub_model(Instance,
      :host => "MyString",
      :port => "MyString",
      :priority => 1
    ).as_new_record)
  end

  it "renders new instance form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => instances_path, :method => "post" do
      assert_select "input#instance_host", :name => "instance[host]"
      assert_select "input#instance_port", :name => "instance[port]"
      assert_select "input#instance_priority", :name => "instance[priority]"
    end
  end
end
