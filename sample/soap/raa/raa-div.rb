require 'div'
require 'singleton'
require 'RAA'; include RAA
require 'soap/driver'
require 'logger'
require 'hotpage'
require 'mutexm'

class RAADiv < Div::Div
  include Singleton
  include MutexM

  attr_accessor :server
  attr_accessor :proxy
  attr_accessor :size

  DefaultRAAServer = 'http://raa.ruby-lang.org/soap/1.0/'

  InitialCoverSec = 7 * 24 * 3600	# 1 week
  CoverSec = 30 * 60			# 30 min
  UpdateInterval = 5 * 60		# 5 min

  def initialize
    @size = 10
    @session = nil
    @div_class = type.to_s
    @div_id = self.id.to_s
    @action = nil

    @server = DefaultRAAServer
    @proxy = nil
    @raa = RAA::Driver.new( @server, @proxy )
    @raa.setLogDev( '/var/tmp/raa-div.log' )
    @raa.setLogLevel( Logger::Severity::INFO )
    @hotItemPool = HotPage.new( &self.method( :hotOrder ))

    @t = Thread.new { poll }
  end

  def to_html(context)
    "<p>RAA</p>\n" <<
    "<ul>\n" <<
      hotitem.collect { | info |
	productName = info.product.name
	version = info.product.version
	author = info.owner.name
	d = info.update
	t = Time.gm( d.year, d.mon, d.mday, d.hour, d.min, d.sec ).localtime
	update = format( '%02d-%02dT%02d:%02d', t.mon, t.mday, t.hour, t.min )
	<<__HERE__
<li><a href="http://www.ruby-lang.org/en/raa-list.rhtml?name=#{ u( productName ) }">#{ productName }/#{ version }</a> [#{ info.category }]<br />
by #{ author }, #{ update }</li>
__HERE__
      }.join( "" ) <<
    "</ul>\n"
  end

private

  def hotitem
    synchronize do
      @hotItemPool.pages[ 0, @size ]
    end
  end

  def poll
    milestone = Time.at( Time.now.gmtime - InitialCoverSec )
    while true
      begin
      t = milestone
      milestone = Time.at( Time.now.gmtime - CoverSec )
	items = @raa.getModifiedInfoSince( t )
	synchronize do
	  oldItems = @hotItemPool.__pages
	  items.each do |item|
	    @hotItemPool << item unless oldItems.find { |i| i.eql?( item ) }
	  end
	end
	@raa.log.info "Got #{ items.size } items."
	sleep UpdateInterval
      rescue Exception
	@raa.log.fatal $!
      end
    end
  end

  def hotOrder( a, b )
    b.update <=> a.update
  end
end

if __FILE__ == $0
  a = RAADiv.instance
  while true
    p a.to_html(nil)
    sleep 10
  end
end
