require 'test/unit'

rcsid = %w$Id: runner.rb,v 1.4 2003/10/18 15:10:29 nahi Exp $
Version = rcsid[2].scan(/\d+/).collect!(&method(:Integer)).freeze
Release = rcsid[3].freeze

runner = Test::Unit::AutoRunner.new(true)
runner.to_run.concat(ARGV)
runner.to_run << File.dirname(__FILE__) if runner.to_run.empty?
runner.run
