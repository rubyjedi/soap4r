class InstalledFile
  attr_reader :path
  attr_reader :mtime

  def initialize( filePath )
    @path = filePath
    @mtime = File.stat( filePath ).mtime
  end

  def ==( rhs )
    self.path == rhs.path
  end

  def match( rhs )
    self.path == rhs.path and self.mtime == rhs.mtime
  end

  def uninstall
    File.unlink( self.path )
  end
end

class InstalledFiles < Array
  Repository = '__installedFiles.db'

  def initialize( dir = '.' )
    load( dir ) if dir
  end

  def uninstall( target )
    if include?( target )
      if checkRemove( target )
	target.uninstall
	delete!( target )
	return true
      else
	STDERR.puts "File: #{ target.path } seems to be modified.  It has not been uninstalled.  Please remove the file manually if you want."
	return false
      end
    end
    false
  end

  def load( dir = '.' )
    path = File.join( dir, Repository )
    if File.exist?( path )
      self.clear
      File.open( path, "rb" ) do | f |
	Marshal.load( f ).each do | package |
	  self << package
	end
      end
    end
  end

  def dump( dir = '.' )
    pack!
    path = File.join( dir, Repository )
    File.open( path, "wb" ) do | f |
      f << Marshal.dump( self )
    end
  end

private

  def pack!
    self.replace( pack )
    nil
  end

  def pack
    newObj = self.class.new( false )
    reverse_each do | package |
      newObj << package unless newObj.include?( package )
    end
    newObj
  end

  def delete!( target )
    self.replace( delete( target ))
    nil
  end

  def delete( target )
    newObj = self.class.new( false )
    each do | package |
      newObj << package unless package == target
    end
    newObj
  end

  def checkRemove( target )
    each do | package |
      return true if package.match( target )
    end
    false
  end
end
