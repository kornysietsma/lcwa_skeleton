require File.join(File.dirname(__FILE__),'/spec_helper')
require 'ostruct'
require File.join(PRJ_DIR,"lib/ostruct_ext")

describe "OpenStruct builder" do

  it "should default to normal openstruct behaviour" do
    struct = OpenStruct.build_recursive({:a => "a", :b => "b"})
    struct.a.should == "a"
    struct.b.should == "b"
  end
  it "should recurse into child hashes" do
    struct = OpenStruct.build_recursive({
            :a => "a",
            :b => {
                    :c => "c",
                    :d => {
                            :e => "e"
                    }
            }
                                        })
    struct.a.should == "a"
    struct.b.c.should == "c"
    struct.b.d.e.should == "e"
  end
  it "should recurse into child arrays" do
    struct = OpenStruct.build_recursive({
            :array => ["a","b","c"],
            :nested => ["a","b",{:foo => "bar"}],
            :subnested => [{:foo => [{:bar => "baz"}]}]
            })
    struct.array.should == ["a","b","c"]
    struct.nested.first.should == "a"
    struct.nested.last.foo.should == "bar"
    struct.subnested.first.foo.first.bar.should == "baz"
  end
  it "should confusingly return primitives and arrays as their own type" do
    OpenStruct.build_recursive("a").should == "a"
    OpenStruct.build_recursive(["a","b"]).should == ["a","b"]
  end
end