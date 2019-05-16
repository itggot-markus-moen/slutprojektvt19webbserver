require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require 'byebug'
require_relative "model.rb"

enable :sessions

include Model

before do
    if session[:account] == nil
        session[:account] = {}
    end
    if session[:account]["logged_in"] != true && request.path_info != '/' && request.path_info != '/login' && request.path_info != '/createaccount'
        redirect('/')
    end
end

# Displays Landing Page
#
get('/') do
    slim(:index)
end

# Displays characters sorted by ownership
#
get('/home') do
    names = list(session[:account][:login]["User_Id"])
    slim(:home, locals:{names:names})
end

# Attempts to login, updates the session and redirects to '/home'
#
# @param [string] Username, The username of the person who attempts to log in
# @param [string] Password, The password of the person who attempts to log in
#
# @see Model#login
post('/login') do
    username = params["Username"]
    password = params["Password"]

    session[:account][:login] = login(username, password)
   
    if session[:account][:login]["Success"]
        session[:account]["logged_in"] = true
        redirect("/home")
    else
        session[:account]["logged_in"] = false
        redirect("/")
    end
end

# Creates a new account and updates the session
#
# @param [string] Username, The username of the person who attempts to register
# @param [string] Password, The password of the person who attempts to register
#
# @see Model#createaccount
post('/createaccount') do
    username = params["Username"]
    password = params["Password"]
    session[:account]["logged_in"] = nil
    session[:account][:username] = nil

    success = createaccount(username, password)
    if success == false
        session[:account][:username] = false
    end
    
    redirect('/')
end

# Clears the session and redirects to '/'
#
post('/logout') do
    session[:account] = nil
    redirect('/')
end

# Displays a selected character
#
# @param [integer] id, The ID of the selected character
#
# @see Model#character
# @see Model#ownership
get('/view/:id') do
    id = params["id"]
    user_id = session[:account][:login]["User_Id"]
    character = character(id)
    character["Character_Id"] = id
    ownership = ownership(user_id, id)
    character["Ownership"] = ownership

    slim(:view, locals:{character:character})
end

# Creates a new character with a given name and redirects to '/view/id'
#
# @param [string] Name, The name of the new character
#
# @see Model#generator
# @see Model#creation
post('/creation') do
    session[:account][:character_name] = nil
    id = creation(generator(params["Name"]), session[:account][:login]["User_Id"])

    if id == false
        session[:account][:character_name] = false
        redirect('/home')
    end
    redirect("/view/#{id}")
end

# Shares ownership of a character with another account
#
# @param [integer] Character_Id, The ID of the shared character
#
# @see Model#share
post('/share') do
    session[:account][:share] = nil
    id = params["Character_Id"]
    result = share(id, params["Username"])
    if result == false
        session[:account][:share] = false
    end
    redirect("/view/#{id}")
end

# Deletes a selected character and redirects to '/home'
#
# @param [string] Character_Id, The ID of the selected character
#
# @see Model#delete
post('/delete') do
    user_id = session[:account][:login]["User_Id"]
    delete(params["Character_Id"], user_id)
    redirect('/home')
end

# Updates a selected character with generated data
#
# @param [string] Character_Id, The ID of the selected character
#
# @see Model#generator
# @see Model#recreate
post('/recreate') do
    recreate(generator(nil), params["Character_Id"])
    redirect("/view/#{params["Character_Id"]}")
end