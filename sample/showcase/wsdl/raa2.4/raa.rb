require 'xsd/qname'

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}Gem
#   id - SOAP::SOAPInt
#   category - Category
#   owner - Owner
#   project - Project
#   updated - SOAP::SOAPDateTime
#   created - SOAP::SOAPDateTime
class Gem
  attr_accessor :id
  attr_accessor :category
  attr_accessor :owner
  attr_accessor :project
  attr_accessor :updated
  attr_accessor :created

  def initialize(id = nil, category = nil, owner = nil, project = nil, updated = nil, created = nil)
    @id = id
    @category = category
    @owner = owner
    @project = project
    @updated = updated
    @created = created
  end
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}Category
#   major - SOAP::SOAPString
#   minor - SOAP::SOAPString
class Category
  attr_accessor :major
  attr_accessor :minor

  def initialize(major = nil, minor = nil)
    @major = major
    @minor = minor
  end
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}Owner
#   id - SOAP::SOAPInt
#   email - SOAP::SOAPAnyURI
#   name - SOAP::SOAPString
class Owner
  attr_accessor :id
  attr_accessor :email
  attr_accessor :name

  def initialize(id = nil, email = nil, name = nil)
    @id = id
    @email = email
    @name = name
  end
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}Project
#   name - SOAP::SOAPString
#   short_description - SOAP::SOAPString
#   version - SOAP::SOAPString
#   status - SOAP::SOAPString
#   url - SOAP::SOAPAnyURI
#   download - SOAP::SOAPAnyURI
#   license - SOAP::SOAPString
#   description - SOAP::SOAPString
#   description_style - SOAP::SOAPString
#   updated - SOAP::SOAPDateTime
#   history - ProjectArray
#   dependency - ProjectDependencyArray
class Project
  attr_accessor :name
  attr_accessor :short_description
  attr_accessor :version
  attr_accessor :status
  attr_accessor :url
  attr_accessor :download
  attr_accessor :license
  attr_accessor :description
  attr_accessor :description_style
  attr_accessor :updated
  attr_accessor :history
  attr_accessor :dependency

  def initialize(name = nil, short_description = nil, version = nil, status = nil, url = nil, download = nil, license = nil, description = nil, description_style = nil, updated = nil, history = nil, dependency = nil)
    @name = name
    @short_description = short_description
    @version = version
    @status = status
    @url = url
    @download = download
    @license = license
    @description = description
    @description_style = description_style
    @updated = updated
    @history = history
    @dependency = dependency
  end
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}ProjectDependency
#   project - SOAP::SOAPString
#   version - SOAP::SOAPString
#   description - SOAP::SOAPString
class ProjectDependency
  attr_accessor :project
  attr_accessor :version
  attr_accessor :description

  def initialize(project = nil, version = nil, description = nil)
    @project = project
    @version = version
    @description = description
  end
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}GemArray
class GemArray < ::Array
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}OwnerArray
class OwnerArray < ::Array
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}ProjectArray
class ProjectArray < ::Array
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}ProjectDependencyArray
class ProjectDependencyArray < ::Array
end

# {http://www.ruby-lang.org/xmlns/soap/type/RAA/0.0.3/}StringArray
class StringArray < ::Array
end
