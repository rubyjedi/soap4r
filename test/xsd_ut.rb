require 'runit/testcase'
require 'runit/cui/testrunner'

require '../lib/soap/XMLSchemaDatatypes'

class TestXSD < RUNIT::TestCase
  include XSD

public
  def setup
    # Nothing to do.
  end

  def teardown
    # Nothing to do.
  end

  def assertParsedResult( klass, str )
    o = klass.new( str )
    assert_equal( str, o.to_s )
  end

  def test_NSDBase
    o = NSDBase.new( 'name', 'ns' )
    assert_equal( 'name', o.typeName )
    assert_equal( 'ns', o.typeNamespace )
    o.typeName = 'name2'
    o.typeNamespace = 'ns2'
    assert_equal( 'name2', o.typeName )
    assert_equal( 'ns2', o.typeNamespace )
    assert( o.typeEqual( 'ns2', 'name2' ))
    assert( !o.typeEqual( 'ns', 'name2' ))
    assert( !o.typeEqual( 'ns2', 'name' ))
    assert( !o.typeEqual( 'ns', 'name' ))
  end

  def test_XSDBase
    o = XSDBase.new( 'typeName' )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
    assert_equal( '', o.to_s )
    assert_exception( NotImplementError ) do
      o.set( 'newData' )
    end
  end

  def test_XSDNil
    o = XSDNil.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( NilLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDBoolean
    o = XSDBoolean.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( BooleanLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDString
    o = XSDString.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( StringLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDDecimal
    o = XSDDecimal.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( DecimalLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDFloat
    o = XSDFloat.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( FloatLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDDouble
    o = XSDDouble.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( DoubleLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDHexBinary
    o = XSDHexBinary.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( HexBinaryLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDBase64Binary
    o = XSDBase64Binary.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( Base64BinaryLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDanyURI
    o = XSDanyURI.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( AnyURILiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    # Too few tests here I know.  Believe uri module. :)
    targets = [
      "foo",
      "http://foo",
      "http://foo/bar/baz",
      "http://foo/bar#baz",
      "http://foo/bar%20%20?a+b",
      "HTTP://FOO/BAR%20%20?A+B",
    ]
    targets.each do | str |
      assertParsedResult( XSDanyURI, str )
    end
  end

  def test_XSDQName
    o = XSDQName.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( QNameLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    # More strict test is needed but current implementation allows all non-':'
    # chars like ' ', C0 or C1...
    targets = [
      "foo",
      "foo:bar",
      "a:b",
    ]
    targets.each do | str |
      assertParsedResult( XSDQName, str )
    end
  end

  def test_XSDDateTime
    o = XSDDateTime.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( DateTimeLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "2002-05-18T16:52:20Z",
      "0000-01-01T00:00:00Z",
      "9999-12-31T23:59:59Z",
      "19999-12-31T23:59:59Z",
      "2002-12-31T23:59:59.999Z",
      "2002-12-31T23:59:59.001Z",
      "2002-12-31T23:59:59.99999999999999999999Z",
      "2002-12-31T23:59:59.00000000000000000001Z",
      "2002-12-31T23:59:59+09:00",
      "2002-12-31T23:59:59+00:01",
      "2002-12-31T23:59:59-00:01",
      "2002-12-31T23:59:59-23:59",
      "2002-12-31T23:59:59.00000000000000000001+13:30",
      "-2002-05-18T16:52:20Z",
      "-19999-12-31T23:59:59Z",
      "-2002-12-31T23:59:59+00:01",
      "-0001-12-31T23:59:59.00000000000000000001+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDDateTime, str )
    end

    targets = [
      [ "2002-12-31T23:59:59.00",
	"2002-12-31T23:59:59Z" ],
      [ "2002-12-31T23:59:59+00:00",
	"2002-12-31T23:59:59Z" ],
      [ "2002-12-31T23:59:59-00:00",
	"2002-12-31T23:59:59Z" ],
      [ "-2002-12-31T23:59:59.00",
	"-2002-12-31T23:59:59Z" ],
      [ "-2002-12-31T23:59:59+00:00",
	"-2002-12-31T23:59:59Z" ],
      [ "-2002-12-31T23:59:59-00:00",
	"-2002-12-31T23:59:59Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDDateTime.new( data ).to_s )
    end
  end

  def test_XSDTime
    o = XSDTime.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( TimeLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "16:52:20Z",
      "00:00:00Z",
      "23:59:59Z",
      "23:59:59.999Z",
      "23:59:59.001Z",
      "23:59:59.99999999999999999999Z",
      "23:59:59.00000000000000000001Z",
      "23:59:59+09:00",
      "23:59:59+00:01",
      "23:59:59-00:01",
      "23:59:59-23:59",
      "23:59:59.00000000000000000001+13:30",
      "23:59:59+00:01",
    ]
    targets.each do | str |
      assertParsedResult( XSDTime, str )
    end

    targets = [
      [ "23:59:59.00",
	"23:59:59Z" ],
      [ "23:59:59+00:00",
	"23:59:59Z" ],
      [ "23:59:59-00:00",
	"23:59:59Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDTime.new( data ).to_s )
    end
  end

  def test_XSDDate
    o = XSDDate.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( DateLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "2002-05-18Z",
      "0000-01-01Z",
      "9999-12-31Z",
      "19999-12-31Z",
      "2002-12-31+09:00",
      "2002-12-31+00:01",
      "2002-12-31-00:01",
      "2002-12-31-23:59",
      "2002-12-31+13:30",
      "-2002-05-18Z",
      "-19999-12-31Z",
      "-2002-12-31+00:01",
      "-0001-12-31+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDDate, str )
    end

    targets = [
      [ "2002-12-31",
	"2002-12-31Z" ],
      [ "2002-12-31+00:00",
	"2002-12-31Z" ],
      [ "2002-12-31-00:00",
	"2002-12-31Z" ],
      [ "-2002-12-31",
	"-2002-12-31Z" ],
      [ "-2002-12-31+00:00",
	"-2002-12-31Z" ],
      [ "-2002-12-31-00:00",
	"-2002-12-31Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDDate.new( data ).to_s )
    end
  end

  def test_XSDDuration
    o = XSDDuration.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( DurationLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "P1234Y5678M9012DT3456H7890M1234.5678S",
      "P0DT3456H7890M1234.5678S",
      "P1234Y5678M9012D",
      "-P1234Y5678M9012DT3456H7890M1234.5678S",
      "P5678M9012DT3456H7890M1234.5678S",
      "-P1234Y9012DT3456H7890M1234.5678S",
      "+P1234Y5678MT3456H7890M1234.5678S",
      "P1234Y5678M9012DT7890M1234.5678S",
      "-P1234Y5678M9012DT3456H1234.5678S",
      "+P1234Y5678M9012DT3456H7890M",
      "P123400000000000Y",
      "-P567800000000000M",
      "+P901200000000000D",
      "P0DT345600000000000H",
      "-P0DT789000000000000M",
      "+P0DT123400000000000.000000000005678S",
      "P1234YT1234.5678S",
      "-P5678MT7890M",
      "+P9012DT3456H",
    ]
    targets.each do | str |
      assertParsedResult( XSDDuration, str )
    end

    targets = [
      [ "P01234Y5678M9012DT3456H7890M1234.5678S",
        "P1234Y5678M9012DT3456H7890M1234.5678S" ],
      [ "P1234Y005678M9012DT3456H7890M1234.5678S",
        "P1234Y5678M9012DT3456H7890M1234.5678S" ],
      [ "P1234Y5678M0009012DT3456H7890M1234.5678S",
        "P1234Y5678M9012DT3456H7890M1234.5678S" ],
      [ "P1234Y5678M9012DT00003456H7890M1234.5678S",
        "P1234Y5678M9012DT3456H7890M1234.5678S" ],
      [ "P1234Y5678M9012DT3456H000007890M1234.5678S",
        "P1234Y5678M9012DT3456H7890M1234.5678S" ],
      [ "P1234Y5678M9012DT3456H7890M0000001234.5678S",
        "P1234Y5678M9012DT3456H7890M1234.5678S" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDDuration.new( data ).to_s )
    end
  end

  def test_XSDgYearMonth
    o = XSDgYearMonth.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( GYearMonthLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "2002-05Z",
      "0000-01Z",
      "9999-12Z",
      "19999-12Z",
      "2002-12+09:00",
      "2002-12+00:01",
      "2002-12-00:01",
      "2002-12-23:59",
      "2002-12+13:30",
      "-2002-05Z",
      "-19999-12Z",
      "-2002-12+00:01",
      "-0001-12+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDgYearMonth, str )
    end

    targets = [
      [ "2002-12",
	"2002-12Z" ],
      [ "2002-12+00:00",
	"2002-12Z" ],
      [ "2002-12-00:00",
	"2002-12Z" ],
      [ "-2002-12",
	"-2002-12Z" ],
      [ "-2002-12+00:00",
	"-2002-12Z" ],
      [ "-2002-12-00:00",
	"-2002-12Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDgYearMonth.new( data ).to_s )
    end
  end

  def test_XSDgYear
    o = XSDgYear.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( GYearLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "2002Z",
      "0000Z",
      "9999Z",
      "19999Z",
      "2002+09:00",
      "2002+00:01",
      "2002-00:01",
      "2002-23:59",
      "2002+13:30",
      "-2002Z",
      "-19999Z",
      "-2002+00:01",
      "-0001+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDgYear, str )
    end

    targets = [
      [ "2002",
	"2002Z" ],
      [ "2002+00:00",
	"2002Z" ],
      [ "2002-00:00",
	"2002Z" ],
      [ "-2002",
	"-2002Z" ],
      [ "-2002+00:00",
	"-2002Z" ],
      [ "-2002-00:00",
	"-2002Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDgYear.new( data ).to_s )
    end
  end

  def test_XSDgMonthDay
    o = XSDgMonthDay.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( GMonthDayLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "05-18Z",
      "01-01Z",
      "12-31Z",
      "12-31+09:00",
      "12-31+00:01",
      "12-31-00:01",
      "12-31-23:59",
      "12-31+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDgMonthDay, str )
    end

    targets = [
      [ "12-31",
	"12-31Z" ],
      [ "12-31+00:00",
	"12-31Z" ],
      [ "12-31-00:00",
	"12-31Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDgMonthDay.new( data ).to_s )
    end
  end

  def test_XSDgDay
    o = XSDgDay.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( GDayLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "18Z",
      "01Z",
      "31Z",
      "31+09:00",
      "31+00:01",
      "31-00:01",
      "31-23:59",
      "31+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDgDay, str )
    end

    targets = [
      [ "31",
	"31Z" ],
      [ "31+00:00",
	"31Z" ],
      [ "31-00:00",
	"31Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDgDay.new( data ).to_s )
    end
  end

  def test_XSDgMonth
    o = XSDgMonth.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( GMonthLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )

    targets = [
      "05Z",
      "01Z",
      "12Z",
      "12+09:00",
      "12+00:01",
      "12-00:01",
      "12-23:59",
      "12+13:30",
    ]
    targets.each do | str |
      assertParsedResult( XSDgMonth, str )
    end

    targets = [
      [ "12",
	"12Z" ],
      [ "12+00:00",
	"12Z" ],
      [ "12-00:00",
	"12Z" ],
    ]
    targets.each do | data, expected |
      assert_equal( expected, XSDgMonth.new( data ).to_s )
    end
  end


  ###
  ## Derived types
  #

  def test_XSDInteger
    o = XSDInteger.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( IntegerLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDLong
    o = XSDLong.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( LongLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end

  def test_XSDInt
    o = XSDInt.new
    assert_equal( Namespace, o.typeNamespace )
    assert_equal( IntLiteral, o.typeName )
    assert_equal( nil, o.data )
    assert_equal( true, o.isNil )
  end
end

if $0 == __FILE__
  testrunner = RUNIT::CUI::TestRunner.new
  if ARGV.size == 0
    suite = TestXSD.suite
  else
    suite = RUNIT::TestSuite.new
    ARGV.each do |testmethod|
      suite.add_test( TestXSD.new( testmethod ))
    end
  end
  testrunner.run(suite)
end
