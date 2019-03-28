require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "control.rb"

enable :sessions

get('/') do
    slim(:index)
end

before do
    p "HAPPY FUN LAND!"
end

get('/temp') do
    slim(:temp)
end

get('/whoops') do
    slim(:whoops)
end

post('/login') do
    username = params["Username"]
    password = params["Password"]

    session[:login] = login(username, password)

    redirect('/temp')
   
#     if username_db[0] != nil && password_db[0] != nil
#         username_db = username_db[0][0]
#         password_db = password_db[0][0]
#     else
#         session[:account]["logged_in"] = false
#         redirect("/")
#     end    
#     if username_db == username
#         if BCrypt::Password.new(password_db) == password
#             session[:account]["logged_in"] = true
#             session[:account]["Username"] = username
#             session[:account]["User_Id"] = db.execute("Select User_Id from Users WHERE Username = ?", username)
#             redirect("/granted")
#         end
#     end
#     session[:account]["logged_in"] = false
#     redirect("/")
end

# post('/newuser') do
#     db = SQLite3::Database.new('db/blogg.db')
#     db.results_as_hash = true

#     secret_password = BCrypt::Password.create(params["Password"])
#     username = params["Username"]
#     email = params["Email"]

#     db.execute("INSERT INTO Users(Username, Password, Email) VALUES(?, ?, ?)", username, secret_password, email)

#     redirect('/')
# end