require 'iSampleStruct'

class SampleStructService
  def hi( sampleStruct )
    howAreYou = SampleStruct.new
    howAreYou.wrap( sampleStruct )
    howAreYou
  end
end

if __FILE__ == $0
  p SampleStructService.new.hi( SampleStruct.new )
end
