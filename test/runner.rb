require 'test/unit'

STDOUT.sync = true
STDERR.sync = true
rcsid = %w$Id: runner.rb,v 1.6 2004/03/26 16:41:49 nahi Exp $
Version = rcsid[2].scan(/\d+/).collect!(&method(:Integer)).freeze
Release = rcsid[3].freeze

exit Test::Unit::AutoRunner.run(false, File.dirname($0))
