#!/usr/bin/env ruby

$KCODE = 'SJIS'

require 'soap/driver'

require 'IICD'
include IICD

proxy = ARGV.shift || nil
server = 'http://www.iwebmethod.net/icd1.0/icd.asmx'

icd = SOAP::Driver.new( nil, $0, IICD::InterfaceNS, server, proxy )
icd.setDefaultEncodingStyle( SOAP::EncodingStyleHandlerASPDotNet::Namespace )
IICD::addMethod( icd )

puts "キーワード: 'microsoft'で見出し検索"
result = icd.SearchWord( 'microsoft', true )

id = nil
result.WORD.each do | word |
  puts "Title: " << word.title
  puts "Id: " << word.id
  puts "English: " << word.english
  puts "Japanese: " << word.japanese
  puts "----"
  id = word.id
end

item = icd.GetItemById( id )
puts
puts
puts "Title: " << item.word.title
puts "意味: " << item.meaning

#p icd.EnumWords

puts
puts
puts "キーワード: 'IBM'で全文検索"
icd.FullTextSearch( "IBM" ).WORD.each do | word |
  puts "Title: " << word.title
  puts "Id: " << word.id
  puts "English: " << word.english
  puts "Japanese: " << word.japanese
  puts "----"
end
