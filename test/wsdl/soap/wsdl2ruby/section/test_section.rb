require 'test/unit'
require 'soap/marshal'
module WSDL; module SOAP


class TestSection < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    system("cd #{DIR} && ruby #{pathname("../../../../../bin/xsd2ruby.rb")} --xsd #{pathname("section.xsd")} --force --quiet")
  end

  def teardown
  end

  def test_classdef
    compare("expectedClassdef.rb", "mysample.rb")
    File.unlink(pathname("mysample.rb"))
  end

  def test_marshal
    require pathname('mysample.rb')
    s1 = Section.new(1, "section1", "section 1", 1001, Question.new("q1"))
    s2 = Section.new(2, "section2", "section 2", 1002, Question.new("q2"))
    org = SectionArray[s1, s2]
    obj = ::SOAP::Marshal.unmarshal(::SOAP::Marshal.marshal(org))
    assert_equal(SectionArray, obj.class)
    assert_equal(Section, obj[0].class)
    assert_equal(Question, obj[0].firstQuestion.class)
  end

private

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    assert_equal(loadfile(expected), loadfile(actual), expected)
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end
end


end; end
