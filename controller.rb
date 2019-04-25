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
    if session[:account]["logged_in"] != true && request.path_info != '/' && request.path_info != '/login' && request.path_info != '/createaccount'
        redirect('/')
    end
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
    session[:account]["logged_in"] = nil
    session[:account][:occupied] = nil

    success = createaccount(username, password)
    if success == false
        session[:account][:occupied] = true
    end
    
    redirect('/')
end

post('/logout') do
    session[:account] = nil
    redirect('/')
end

get('/view/:id') do
    id = params["id"]
    user_id = session[:account][:login]["User_Id"]
    character = character(id)
    character["Character_Id"] = id
    ownership = ownership(user_id, id)
    character["Ownership"] = ownership

    slim(:view, locals:{character:character})
end

post('/creation') do
    id = creation(params["Name"])
    redirect("/view/#{id}")
end

post('/share') do
    id = params["Character_Id"]
    share(id, params["Username"])
    redirect("/view/#{id}")
end