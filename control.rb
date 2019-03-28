require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

def login(username, password)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    user_id = db.execute("SELECT User_Id from Users WHERE Username = ?", username)
    if user_id != []
        user_id = user_id[0][0]
        password_db = db.execute("SELECT Password from Users WHERE User_Id = ?", user_id)
        password_db = password_db[0][0]
    else
        redirect('/whoops')
    end

    return {"User_Id" => user_id, "Password" => password_db}
end