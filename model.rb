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

def character(character_id)
    db = SQLite3::Database.new('db/db.db')
    # db.results_as_hash = true

    name = db.execute("SELECT Name FROM Characters WHERE Character_Id = ?", character_id)
    clas = db.execute("Select Class FROM Classes INNER JOIN Characters ON Classes.Class_Id = Characters.Class_Id WHERE Character_Id = ?", character_id)
    subclass = db.execute("Select Subclass FROM Subclasses INNER JOIN Characters ON Subclasses.Subclass_Id = Characters.Subclass_Id WHERE Character_Id = ?", character_id)
    race = db.execute("Select Race FROM Races INNER JOIN Characters ON Races.Race_Id = Characters.Race_Id WHERE Character_Id = ?", character_id)
    subrace = db.execute("Select Subrace FROM Subraces INNER JOIN Characters ON Subraces.Subrace_Id = Characters.Subrace_Id WHERE Character_Id = ?", character_id)
    background = db.execute("Select Background FROM Backgrounds INNER JOIN Characters ON Backgrounds.Background_Id = Characters.Background_Id WHERE Character_Id = ?", character_id)

    character = {"Name" => name, "Class" => clas[0], "Subclass" => subclass[0], "Subrace" => subrace[0], "Background" => background[0]}
    return character
end

def list(user_id)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    your_characters = db.execute("SELECT Characters.Name, Characters.Character_Id from Characters INNER JOIN Ownership ON Characters.Character_Id = Ownership.Character_Id WHERE User_Id = ?", user_id)
    not_your_characters = db.execute("SELECT Characters.Name, Characters.Character_Id from Characters INNER JOIN Ownership ON Characters.Character_Id = Ownership.Character_Id WHERE User_Id != ?", user_id)
    return your_characters, not_your_characters
end