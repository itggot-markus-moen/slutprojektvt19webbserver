require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require 'byebug'

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
    
    taken = db.execute("SELECT Username FROM Users WHERE Username = ?", username)
    if taken.length != 0 || username.length == 0
        return false
    end

    secret_password = BCrypt::Password.create(password)
    db.execute("INSERT INTO Users(Username, Password) VALUES(?, ?)", username, secret_password)
end

def character(character_id)
    db = SQLite3::Database.new('db/db.db')
    # db.results_as_hash = true

    name = db.execute("SELECT Name FROM Characters WHERE Character_Id = ?", character_id)
    while name.kind_of?(Array)
        name = name[0]
    end
    clas = db.execute("Select Class FROM Classes INNER JOIN Characters ON Classes.Class_Id = Characters.Class_Id WHERE Character_Id = ?", character_id)
    while clas.kind_of?(Array)
        clas = clas[0]
    end
    subclass = db.execute("Select Subclass FROM Subclasses INNER JOIN Characters ON Subclasses.Subclass_Id = Characters.Subclass_Id WHERE Character_Id = ?", character_id)
    while subclass.kind_of?(Array)
        subclass = subclass[0]
    end
    race = db.execute("Select Race FROM Races INNER JOIN Characters ON Races.Race_Id = Characters.Race_Id WHERE Character_Id = ?", character_id)
    while race.kind_of?(Array)
        race = race[0]
    end
    subrace = db.execute("Select Subrace FROM Subraces INNER JOIN Characters ON Subraces.Subrace_Id = Characters.Subrace_Id WHERE Character_Id = ?", character_id)
    while subrace.kind_of?(Array)
        subrace = subrace[0]
    end
    background = db.execute("Select Background FROM Backgrounds INNER JOIN Characters ON Backgrounds.Background_Id = Characters.Background_Id WHERE Character_Id = ?", character_id)
    while background.kind_of?(Array)
        background = background[0]
    end

    character = {"Name" => name, "Class" => clas, "Subclass" => subclass, "Race" => race, "Subrace" => subrace, "Background" => background}
    return character
end

def list(user_id)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    your_characters = db.execute("SELECT Characters.Name, Characters.Character_Id from Characters INNER JOIN Ownership ON Characters.Character_Id = Ownership.Character_Id WHERE User_Id = ?", user_id)
    not_your_characters = db.execute("SELECT Characters.Name, Characters.Character_Id from Characters INNER JOIN Ownership ON Characters.Character_Id = Ownership.Character_Id WHERE User_Id != ?", user_id)
    return your_characters, not_your_characters
end

def creation(name)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true

    taken = db.execute("SELECT Name FROM Characters WHERE Name = ?", name)
    if taken.length != 0 or name.length == 0
        return false
    end

    clas = db.execute("SELECT * FROM Classes")
    clas = clas[rand(clas.length)]
    subclass = db.execute("SELECT * FROM Subclasses WHERE Class_Id = ?", clas["Class_Id"])
    subclass = subclass[rand(subclass.length)]
    race = db.execute("SELECT * FROM Races")
    race = race[rand(race.length)]
    subrace = db.execute("SELECT * FROM Subraces WHERE Race_Id = ?", race["Race_Id"])
    subrace = subrace[rand(subrace.length)]
    background = db.execute("SELECT * FROM Backgrounds")
    background = background[rand(background.length)]

    if subrace != nil
        db.execute("INSERT INTO Characters(Name, Class_Id, Subclass_Id, Race_Id, Subrace_Id, Background_Id) VALUES(?, ?, ?, ?, ?, ?)", name, clas[0], subclass[0], race[0], subrace[0], background[0])
    else
        db.execute("INSERT INTO Characters(Name, Class_Id, Subclass_Id, Race_Id, Background_Id) VALUES(?, ?, ?, ?, ?)", name, clas[0], subclass[0], race[0], background[0])
    end

    character_id = db.execute("SELECT Character_Id FROM Characters WHERE Name = ?", name)
    character_id = character_id[0][0]

    db.execute("INSERT INTO Ownership(User_Id, Character_Id) VALUES(?, ?)", session[:account][:login]["User_Id"], character_id)

    return character_id
end

def share(id, username)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    user_id = db.execute("SELECT User_Id FROM Users WHERE Username = ?", username)
    user_id = user_id[0][0]
    db.execute("INSERT INTO Ownership(User_Id, Character_Id) VALUES(?, ?)", id, user_id)
end

def ownership(user_id, character_id)
    db = SQLite3::Database.new('db/db.db')

    output = false
    owners = db.execute("SELECT User_Id FROM Ownership WHERE Character_Id = ?", character_id)
    if owners.include?([user_id])
        output = true
    end
    return output
end