# frozen_string_literal: true

begin
  require "pry-byebug"
rescue LoadError
end
require "representable"

require "minitest/autorun"
require "test_xml/mini_test"

require "representable/debug"
require "minitest/assertions"

module MiniTest
  module Assertions
    def assert_equal_xml(text, subject)
      assert_equal text.delete("\n").gsub(/(\s\s+)/, ""), subject.delete("\n").gsub(/(\s\s+)/, "")
    end
  end
end
String.infect_an_assertion :assert_equal_xml, :must_xml

# TODO: delete all that in 4.0
require_relative "models/album"
require_relative "models/band"
require_relative "models/song"

module XmlHelper
  def xml(document)
    Nokogiri::XML(document).root
  end
end

module AssertJson
  module Assertions
    def assert_json(expected, actual, msg = nil)
      msg = message(msg, "") { diff expected, actual }

      assert_equal(expected.chars.sort, actual.chars.sort, msg)
    end
  end
end

module DocumentAssertions
  def assert_equal_document(expected, actual, msg = nil)
    msg = message(msg) { diff expected, actual }
    return assert_xml_equal(expected, actual) if format == :xml

    assert_equal(expected, actual, msg)
  end
end

module MiniTest
  class Spec
    include AssertJson::Assertions
    include XmlHelper
    include DocumentAssertions

    def self.for_formats(formats)
      formats.each do |format, cfg|
        mod, output, input = cfg
        yield format, mod, output, input
      end
    end

    def render(obj, *args)
      obj.send("to_#{format}", *args)
    end

    def parse(object, input, *args)
      object.send("from_#{format}", input, *args)
    end

    def self.representer!(options = {}, &block)
      fmt = options # we need that so the 2nd call to ::let(within a ::describe) remembers the right format.

      name   = options[:name]   || :representer
      format = options[:module] || Representable::Hash

      let(name) do
        mod = options[:decorator] ? Class.new(Representable::Decorator) : Module.new

        inject_representer(mod, fmt)

        mod.module_eval do
          include format
          instance_exec(&block)
        end

        mod
      end

      undef :inject_representer if method_defined? :inject_representer

      def inject_representer(mod, options)
        return unless options[:inject]

        injected_name = options[:inject]
        injected = send(injected_name) # song_representer
        mod.singleton_class.instance_eval do
          define_method(injected_name) { injected }
        end
      end
    end

    module TestMethods
      def representer_for(modules = [Representable::Hash], &block)
        Module.new do
          extend TestMethods
          include(*modules)
          module_exec(&block)
        end
      end

      alias representer! representer_for
    end
    include TestMethods
  end
end

class BaseTest < MiniTest::Spec
  let(:new_album)  { OpenStruct.new.extend(representer) }
  let(:album)      { OpenStruct.new(songs: ["Fuck Armageddon"]).extend(representer) }
  let(:song) { OpenStruct.new(title: "Resist Stance") }
  let(:song_representer) do
    Module.new do
      include Representable::Hash
      property :title
    end
  end
end
