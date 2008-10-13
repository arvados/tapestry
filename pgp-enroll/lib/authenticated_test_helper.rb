module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @request.session[:user_id] = user ? user.id : nil
  end

  def logout
    @request.session[:user_id] = nil   # keeps the session but kill our variable
  end
end
