class CalcService2
  def initialize( initValue = 0 )
    @value = initValue
  end

  def set( newValue )
    @value = newValue
  end

  def get
    @value
  end

  def +( rhs )
    @value + rhs
  end

  def -( rhs )
    @value - rhs
  end

  def *( rhs )
    @value * rhs
  end

  def /( rhs )
    @value / rhs
  end
end
