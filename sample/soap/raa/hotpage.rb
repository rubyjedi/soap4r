# hotpage.rb
#
# $Id: hotpage.rb,v 1.1 2003/09/24 13:52:06 nahi Exp $
# Copyright (c) 2002 NAKAMURA, Hiroshi
#
# hotpage.rb is copyrighted free software by NAKAMURA, Hiroshi
# You can redistribute it and/or modify it under the same term as Ruby.
#
module HotPageMixIn
  def initialize( &hot_order )
    @hot_order = hot_order || HotPageMixIn.method( :default_hot_order )
    @dirty = false
    @pages = []
    @notify = nil
  end

  def pages
    if dirty?
      update
      unset_dirty
    end
    @pages
  end

  def __pages
    collect_pages
  end

  def include?( item )
    include_item?( item )
  end

  def <<( arg )
    add( arg )
    self
  end

  def add( arg )
    add_item( arg )
    set_dirty
  end

  def delete( arg )
    delete_item( arg )
    set_dirty
  end

  def replace( rhs )
    replace_item( rhs )
    set_dirty
  end

  def notify=( notify )
    @notify = notify
  end

  def set_dirty
    @dirty = true
    @notify.call if @notify
  end

  private
  def collect_pages
    raise NotImplementedError.new(
      "Method 'collect_pages' must be defined in derived class." )
  end

  def update
    raise NotImplementedError.new(
      "Method 'update' must be defined in derived class." )
  end

  def include_item?( arg )
    raise NotImplementedError.new(
      "Method 'include_item?' must be defined in derived class." )
  end

  def add_item( arg )
    raise NotImplementedError.new(
      "Method 'add_item' must be defined in derived class." )
  end

  def delete_item( arg )
    raise NotImplementedError.new(
      "Method 'delete_item' must be defined in derived class." )
  end

  def replace_item( rhs )
    raise NotImplementedError.new(
      "Method 'replace_item' must be defined in derived class." )
  end

  def dirty?
    @dirty
  end

  def unset_dirty
    @dirty = false
  end

  def hot_order( names )
    names.sort( &@hot_order )
  end

  def HotPageMixIn.default_hot_order( a, b )
    a <=> b
  end
end

class HotPageContainer; include HotPageMixIn
  def initialize
    super
    @member = []
  end

  private
  def collect_pages
    pages = []
    @member.each do | m |
      pages.concat( m.__pages )
    end
    pages
  end

  def update
    @pages = hot_order( collect_pages )
  end

  def include_item?( item )
    @member.each do | m |
      if m.include?( item )
	return true
      end
    end
    false
  end

  def add_item( hotpage )
    if !hotpage.is_a?( HotPageMixIn )
      raise ArgumentError.new( "Each argument must be a HotPageMixIn." )
    end
    hotpage.notify = self.method( :set_dirty )
    @member << hotpage
  end

  def delete_item( hotpage )
    @member.delete( hotpage )
  end

  def replace_item( rhs )
    @member.replace( rhs )
  end
end

class HotPage; include HotPageMixIn
  private
  def collect_pages
    @pages
  end

  def update
    @pages = hot_order( @pages )
  end

  def include_item?( item )
    @pages.include?( item )
  end

  def add_item( page )
    @pages << page
  end

  def delete_item( page )
    @pages.delete( page )
  end

  def replace_item( rhs )
    @pages.replace( rhs )
  end
end
