require "test_helper"

class GetterSetterTest < BaseTest
  representer! do
    property :name, # key under :name.
             :getter => ->(user_options:, **) { "#{user_options[:welcome]} #{song_name}" },
             :setter => ->(user_options:, input:, **) { self.song_name = "#{user_options[:welcome]} #{input}" }
  end

  subject { Struct.new(:song_name).new("Mony Mony").extend(representer) }

  it "uses :getter when rendering" do
    subject.instance_eval { def name; fail; end }
    _(subject.to_hash(user_options: {welcome: "Hi"})).must_equal({"name" => "Hi Mony Mony"})
  end

  it "uses :setter when parsing" do
    subject.instance_eval { def name=(*); fail; end; self }
    _(
      subject.from_hash(
        {"name" => "Eyes Without A Face"},
        user_options: {welcome: "Hello"}
      ).song_name
    ).must_equal "Hello Eyes Without A Face"
  end
end
