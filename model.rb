require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

def login(username, password)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    user_id = db.execute("SELECT User_Id from Users WHERE Username = ?", username)
    if user_id != []
        success = true
        user_id = user_id[0][0]
        password_db = db.execute("SELECT Password from Users WHERE User_Id = ?", user_id)
        password_db = password_db[0][0]
    else
        success = false
    end

    return {"User_Id" => user_id, "Password" => password_db, "Success" => success}
end

def createaccount(username, password)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    secret_password = BCrypt::Password.create(password)
    
    db.execute("INSERT INTO Users(Username, Password) VALUES(?, ?)", username, secret_password)
end