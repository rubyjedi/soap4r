require 'test/unit'

STDOUT.sync = true
STDERR.sync = true
rcsid = %w$Id$
Version = rcsid[2].scan(/\d+/).collect!(&method(:Integer)).freeze
Release = rcsid[3].freeze

exit Test::Unit::AutoRunner.run(true, File.dirname($0))
