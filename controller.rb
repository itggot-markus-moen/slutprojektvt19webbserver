require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "model.rb"

enable :sessions

get('/') do
    slim(:index)
end

before do
    if session[:account] == nil
        session[:account] = {}
    end
    # if session[:account]["logged_in"] != true
    #     redirect('/')
    # end
end

get('/temp') do
    slim(:temp)
end

get('/whoops') do
    slim(:whoops)
end

get('/home') do
    names = list(session[:account][:login]["User_Id"])

    slim(:home, locals:{names:names})
end

post('/login') do
    username = params["Username"]
    password = params["Password"]

    session[:account][:login] = login(username, password)
   
    if session[:account][:login]["Success"]
        if BCrypt::Password.new(session[:account][:login]["Password"]) == password
            session[:account]["logged_in"] = true
#             session[:account]["Username"] = username
            redirect("/home")
        else
            session[:account]["logged_in"] = false
        end
    else
        session[:account]["logged_in"] = false
    end
    redirect("/")
end

post('/createaccount') do
    username = params["Username"]
    password = params["Password"]

    createaccount(username, password)

    redirect('/')
end

post('/logout') do
    session[:account] = nil
    redirect('/')
end

get('/view/:id') do
    character = character(params["id"])

    slim(:view, locals:{character:character})
end

post('/creation') do
    creation(params["Name"])
    redirect('/home')
end