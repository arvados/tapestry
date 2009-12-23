class Test::Unit::TestCase
  def trap_exception(exception_class=Exception)
    @exception = nil
    begin
      yield
    rescue exception_class => @exception
    end
  end

  def self.should_raise_exception(exception_class=Exception)
    should "raise #{exception_class.name.humanize.downcase}" do
      assert_kind_of exception_class, @exception
    end
  end

  def self.should_not_raise_exception(exception_class=Exception)
    should "not raise #{exception_class.name.humanize.downcase}" do
      assert !(exception_class === @exception),
             "Didn't expect #{@exception.inspect} to be a #{exception_class.name}"
    end
  end
end
