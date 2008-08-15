u = User.new
u.name = 'Jason Morrison'
u.email = 'jason@example.org'
u.password = 'password'
u.password_confirmation = 'password'
u.save
u.reload
u.activate!

