=begin
SOAP4R - Base type library
Copyright (C) 2000, 2001, 2003  NAKAMURA, Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end

require 'soap/soap'
require 'soap/qname'
require 'soap/XMLSchemaDatatypes'


module SOAP


###
## Mix-in module for SOAP base type classes.
#
module SOAPModuleUtils
  include SOAP

public

  def decode(elename)
    d = self.new
    d.elename = elename
    d
  end
end


###
## Mix-in module for SOAP base type instances.
#
module SOAPBasetype
  include SOAP

  attr_accessor :encodingstyle

  attr_accessor :elename
  attr_accessor :id
  attr_reader :precedents
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position
  attr_reader :extraattr

public

  def initialize(*vars)
    super(*vars)
    @encodingstyle = nil
    @elename = XSD::QName.new
    @id = nil
    @precedents = []
    @parent = nil
    @position = nil
    @extraattr = {}
  end
end


###
## Mix-in module for SOAP compound type instances.
#
module SOAPCompoundtype
  include SOAP

  attr_accessor :encodingstyle

  attr_accessor :elename
  attr_accessor :id
  attr_reader :precedents
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position
  attr_reader :extraattr

  attr_accessor :definedtype

public

  def initialize(type)
    super()
    @type = type
    @encodingstyle = nil
    @elename = XSD::QName.new
    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @position = nil
    @definedtype = nil
    @extraattr = {}
  end
end


###
## Convenience datatypes.
#
class SOAPReference < NSDBase
  include SOAPBasetype
  extend SOAPModuleUtils

public

  attr_accessor :refid
  attr_accessor :elename

  # Override the definition in SOAPBasetype.
  def initialize(refid = nil)
    super()
    @type = XSD::QName.new
    @encodingstyle = nil
    @elename = XSD::QName.new
    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @refid = refid
    @obj = nil
  end

  def __getobj__
    @obj
  end

  def __setobj__(obj)
    @obj = obj
    @refid = SOAPReference.create_refid(@obj)
    @obj.id = @refid unless @obj.id
    @obj.precedents << self
    # Copies NSDBase information
    @obj.type = @type unless @obj.type
  end

  # Why don't I use delegate.rb?
  # -> delegate requires target object type at initialize time.
  # Why don't I use forwardable.rb?
  # -> forwardable requires a list of forwarding methods.
  #
  # ToDo: Maybe I should use forwardable.rb and give it a methods list like
  # delegate.rb...
  #
  def method_missing(msg_id, *params)
    if @obj
      @obj.send(msg_id, *params)
    else
      nil
    end
  end

  def self.decode(elename, refid)
    d = super(elename)
    d.refid = refid
    d
  end

  def SOAPReference.create_refid(obj)
    'id' << obj.__id__.to_s
  end
end

class SOAPNil < XSDNil
  include SOAPBasetype
  extend SOAPModuleUtils
end

# SOAPRawString is for sending raw string.  In contrast to SOAPString,
# SOAP4R does not do XML encoding and does not convert its CES.  The string it
# holds is embedded to XML instance directly as a 'xsd:string'.
class SOAPRawString < XSDString
  include SOAPBasetype
  extend SOAPModuleUtils
end


###
## Basic datatypes.
#
class SOAPAnySimpleType < XSDAnySimpleType
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPString < XSDString
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPBoolean < XSDBoolean
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDecimal < XSDDecimal
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPFloat < XSDFloat
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDouble < XSDDouble
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDuration < XSDDuration
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDateTime < XSDDateTime
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPTime < XSDTime
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDate < XSDDate
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGYearMonth < XSDGYearMonth
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGYear < XSDGYear
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGMonthDay < XSDGMonthDay
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGDay < XSDGDay
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGMonth < XSDGMonth
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPHexBinary < XSDHexBinary
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPBase64 < XSDBase64Binary
  include SOAPBasetype
  extend SOAPModuleUtils
  Type = QName.new(EncodingNamespace, Base64Literal)

public
  # Override the definition in SOAPBasetype.
  def initialize(value = nil)
    super(value)
    @type = Type
  end

  def as_xsd
    @type = XSD::XSDBase64Binary::Type
  end
end

class SOAPAnyURI < XSDAnyURI
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPQName < XSDQName
  include SOAPBasetype
  extend SOAPModuleUtils
end


class SOAPInteger < XSDInteger
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPLong < XSDLong
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPInt < XSDInt
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPShort < XSDShort
  include SOAPBasetype
  extend SOAPModuleUtils
end


###
## Compound datatypes.
#
class SOAPStruct < NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  def initialize(type = nil)
    super(type || XSD::QName.new)
    @array = []
    @data = []
  end

  def to_s()
    str = ''
    self.each do |key, data|
      str << "#{ key }: #{ data }\n"
    end
    str
  end

  def add(name, value)
    add_member(name, value)
  end

  def [](idx)
    if idx.is_a?(Range)
      @data[idx]
    elsif idx.is_a?(Integer)
      if (idx > @array.size)
        raise ArrayIndexOutOfBoundsError.new('In ' << @type.name)
      end
      @data[idx]
    else
      if @array.include?(idx)
	@data[@array.index(idx)]
      else
	nil
      end
    end
  end

  def []=(idx, data)
    if @array.include?(idx)
      @data[@array.index(idx)] = data
    else
      add(idx, data)
    end
  end

  def key?(name)
    @array.include?(name)
  end

  def members
    @array
  end

  def each
    for i in 0..(@array.length - 1)
      yield(@array[i], @data[i])
    end
  end

  def replace
    members.each do |member|
      self[member] = yield(self[member])
    end
  end

  def self.decode(elename, type)
    s = SOAPStruct.new(type)
    s.elename = elename
    s
  end

private

  def add_member(name, value = nil)
    value = SOAPNil.new() unless value
    @array.push(name)
    value.elename.name = name
    @data.push(value)
  end
end


# SOAPElement is not typed so it does not derive NSDBase.
class SOAPElement
  include SOAPCompoundtype
  include Enumerable

public

  attr_accessor :qualified
  attr_accessor :elename

  def initialize(namespace, name, text = nil)
    super(nil)
    @encodingstyle = LiteralNamespace
    @elename = XSD::QName.new(namespace, name)

    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @position = nil

    @qualified = false
    @array = []
    @data = []
    @text = text
  end

  # Text interface.
  attr_accessor :text

  # Element interfaces.
  def add(value)
    add_member(value.name, value)
  end

  def [](idx)
    if @array.include?(idx)
      @data[@array.index(idx)]
    else
      nil
    end
  end

  def []=(idx, data)
    if @array.include?(idx)
      @data[@array.index(idx)] = data
    else
      add(data)
    end
  end

  def key?(name)
    @array.include?(name)
  end

  def members
    @array
  end

  def each
    for i in 0..(@array.length - 1)
      yield(@array[i], @data[i])
    end
  end

  def self.decode(elename)
    o = SOAPElement.new
    o.elename = elename
    o
  end

private

  def add_member(name, value = nil)
    value = SOAPNil.new() unless value
    add_accessor(name)
    @array.push(name)
    value.name = name
    @data.push(value)
  end

  def add_accessor(name)
    methodname = name
    if self.methods.include?(methodname)
      methodname = safe_accessor_name(methodname)
    end
    begin
      instance_eval <<-EOS
        def #{ methodname }()
	  @data[@array.index('#{ name }')]
        end

        def #{ methodname }=(value)
	  @data[@array.index('#{ name }')] = value
        end
      EOS
    rescue SyntaxError
      methodname = safe_accessor_name(methodname)
      retry
    end
  end

  def safe_accessor_name(name)
    "var_" << name.gsub(/[^a-zA-Z0-9_]/, '')
  end
end


class SOAPArray < NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  ArrayEncodePostfix = 'Ary'

  attr_accessor :sparse

  attr_reader :offset, :rank
  attr_accessor :size, :size_fixed
  attr_reader :arytype

  def initialize(type = nil, rank = 1, arytype = nil)
    super(type || XSD::QName.new)
    @rank = rank
    @data = Array.new
    @sparse = false
    @offset = Array.new(rank, 0)
    @size = Array.new(rank, 0)
    @size_fixed = false
    @position = nil
    @arytype = arytype
  end

  def offset=(var)
    @offset = var
    @sparse = true
  end

  def add(value)
    self[*(@offset)] = value
  end

  def [](*idxary)
    if idxary.size != @rank
      raise ArgumentError.new("Given #{ idxary.size } params does not match rank: #{ @rank }")
    end

    retrieve(idxary)
  end

  def []=(*idxary)
    value = idxary.slice!(-1)

    if idxary.size != @rank
      raise ArgumentError.new("Given #{ idxary.size } params(#{ idxary }) does not match rank: #{ @rank }")
    end

    for i in 0..(idxary.size - 1)
      if idxary[i] + 1 > @size[i]
	@size[i] = idxary[i] + 1
      end
    end

    data = retrieve(idxary[0, idxary.size - 1])
    data[idxary.last] = value

    if value.is_a?(SOAPBasetype) || value.is_a?(SOAPCompoundtype)
      value.elename.name = 'item'
      
      # Sync type
      unless @type.name
	@type = XSD::QName.new(value.type.namespace,
	  SOAPArray.create_arytype(value.type.name, @rank))
      end

      unless value.type
	value.type = @type
      end
    end

    @offset = idxary
    offsetnext
  end

  def each
    @data.each do |data|
      yield(data)
    end
  end

  def to_a
    @data.dup
  end

  def replace
    @data = deep_map(@data) do |ele|
      yield(ele)
    end
  end

  def deep_map(ary, &block)
    ary.collect do |ele|
      if ele.is_a?(Array)
	deep_map(ele, &block)
      else
	new_obj = block.call(ele)
	new_obj.elename.name = 'item'
	new_obj
      end
    end
  end

  def include?(var)
    traverse_data(@data) do |v, *rank|
      if v.is_a?(SOAPBasetype) && v.data == var
	return true
      end
    end
    false
  end

  def traverse
    traverse_data(@data) do |v, *rank|
      unless @sparse
       yield(v)
      else
       yield(v, *rank) if v && !v.is_a?(SOAPNil)
      end
    end
  end

  def soap2array(ary)
    traverse_data(@data) do |v, *position|
      iteary = ary
      for rank in 1..(position.size - 1)
	idx = position[rank - 1]
	if iteary[idx].nil?
	  iteary = iteary[idx] = Array.new
	else
	  iteary = iteary[idx]
	end
      end
      if block_given?
	iteary[position.last] = yield(v)
      else
	iteary[position.last] = v
      end
    end
  end

  def position
    @position
  end

private

  def retrieve(idxary)
    data = @data
    for rank in 1..(idxary.size)
      idx = idxary[rank - 1]
      if data[idx].nil?
	data = data[idx] = Array.new
      else
	data = data[idx]
      end
    end
    data
  end

  def traverse_data(data, rank = 1)
    for idx in 0..(ranksize(rank) - 1)
      if rank < @rank
	traverse_data(data[idx], rank + 1) do |*v|
	  v[1, 0] = idx
       	  yield(*v)
	end
      else
	yield(data[idx], idx)
      end
    end
  end

  def ranksize(rank)
    @size[rank - 1]
  end

  def offsetnext
    move = false
    idx = @offset.size - 1
    while !move && idx >= 0
      @offset[idx] += 1
      if @size_fixed
	if @offset[idx] < @size[idx]
	  move = true
	else
	  @offset[idx] = 0
	  idx -= 1
	end
      else
	move = true
      end
    end
  end

  # Module function

public

  def self.decode(elename, type, arytype)
    typestr, nofary = parse_type(arytype.name)
    rank = nofary.count(',') + 1
    plain_arytype = XSD::QName.new(arytype.namespace, typestr)
    o = SOAPArray.new(type, rank, plain_arytype)
    size = []
    nofary.split(',').each do |s|
      if s.empty?
	size.clear
	break
      else
	size << s.to_i
      end
    end
    unless size.empty?
      o.size = size
      o.size_fixed = true
    end
    o.elename = elename
    o
  end

private

  def self.create_arytype(typename, rank)
    "#{ typename }[" << ',' * (rank - 1) << ']'
  end

  TypeParseRegexp = Regexp.new('^(.+)\[([\d,]*)\]$')

  def self.parse_type(string)
    TypeParseRegexp =~ string
    return $1, $2
  end
end


require 'soap/typeMap'


end
