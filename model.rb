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
    ability_scores = db.execute("SELECT Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma FROM Characters WHERE Character_Id = ?", character_id)
    ability_scores = ability_scores[0]

    # character = {"Name" => name, "Class" => clas, "Subclass" => subclass, "Race" => race, "Subrace" => subrace, "Background" => background}
    character = {"Name" => name, "Class" => clas, "Subclass" => subclass, "Race" => race, "Subrace" => subrace, "Background" => background, "Strength" => ability_scores[0], "Dexterity" => ability_scores[1], "Constitution" => ability_scores[2], "Intelligence" => ability_scores[3], "Wisdom" => ability_scores[4], "Charisma" => ability_scores[5]}
    return character
end

def list(user_id)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    your_characters = db.execute("SELECT Characters.Name, Characters.Character_Id from Characters INNER JOIN Ownership ON Characters.Character_Id = Ownership.Character_Id WHERE User_Id = ?", user_id)
    not_your_characters = db.execute("SELECT Characters.Name, Characters.Character_Id from Characters INNER JOIN Ownership ON Characters.Character_Id = Ownership.Character_Id WHERE User_Id != ?", user_id)
    return your_characters, not_your_characters
end

def roller
    d1 = rand(6)+1
    d2 = rand(6)+1
    d3 = rand(6)+1
    d4 = rand(6)+1
    arr =[d1, d2, d3, d4]
    i = 1
    min = arr[0]
    while i < arr.length
        if min > arr[i]
            min = arr[i]
        end
        i += 1
    end
    ability = (d1 + d2 + d3 + d4 - min)
    return ability
end

def generator(name)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    clas = db.execute("SELECT * FROM Classes")
    clas = clas[rand(clas.length)][0]
    subclass = db.execute("SELECT * FROM Subclasses WHERE Class_Id = ?", clas)
    subclass = subclass[rand(subclass.length)][0]
    race = db.execute("SELECT * FROM Races")
    race = race[rand(race.length)][0]
    subrace = db.execute("SELECT * FROM Subraces WHERE Race_Id = ?", race)
    subrace = subrace[rand(subrace.length)]
    if subrace != nil
        subrace = subrace[0]
    end
    background = db.execute("SELECT * FROM Backgrounds")
    background = background[rand(background.length)][0]

    character = {"Name" => name, "Class" => clas, "Subclass" => subclass, "Race" => race, "Subrace" => subrace, "Background" => background, "Strength" => roller(), "Dexterity" => roller(), "Constitution" => roller(), "Intelligence" => roller(), "Wisdom" => roller(), "Charisma" => roller()}
    return character
end

def creation(character_hash)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true

    taken = db.execute("SELECT Name FROM Characters WHERE Name = ?", character_hash["Name"])
    if taken.length != 0 or character_hash["Name"].length == 0
        return false
    end

    db.execute("INSERT INTO Characters(Name, Class_Id, Subclass_Id, Race_Id, Subrace_Id, Background_Id, Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", character_hash["Name"], character_hash["Class"], character_hash["Subclass"], character_hash["Race"], character_hash["Subrace"], character_hash["Background"], character_hash["Strength"], character_hash["Dexterity"], character_hash["Constitution"], character_hash["Intelligence"], character_hash["Wisdom"], character_hash["Charisma"])

    character_id = db.execute("SELECT Character_Id FROM Characters WHERE Name = ?", character_hash["Name"])
    character_id = character_id[0][0]

    db.execute("INSERT INTO Ownership(User_Id, Character_Id) VALUES(?, ?)", session[:account][:login]["User_Id"], character_id)

    return character_id
end
#TODO: Gör så att man inte kan dela med sig själv.
def share(id, username)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    
    user_id = db.execute("SELECT User_Id FROM Users WHERE Username = ?", username)
    if user_id == []
        return false
    end
    user_id = user_id[0][0]
    self_share = db.execute("SELECT * FROM Ownership WHERE User_Id = ? AND Character_Id = ?", user_id, id)
    if self_share != []
        return false
    end
    db.execute("INSERT INTO Ownership(User_Id, Character_Id) VALUES(?, ?)", user_id, id)
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

def delete(character_id, user_id)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true

    if ownership(user_id, character_id)
        db.execute("DELETE FROM Characters WHERE Character_Id = ?", character_id)
        db.execute("DELETE FROM Ownership WHERE Character_Id = ?", character_id)
    end
end

def recreate(character_hash, character_id)
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true

    db.execute("UPDATE Characters SET Class_Id = ?, Subclass_Id = ?, Race_Id = ?, Subrace_Id = ?, Background_Id = ?, Strength = ?, Dexterity = ?, Constitution = ?, Intelligence = ?, Wisdom = ?, Charisma = ? WHERE Character_Id = ?", character_hash["Class"], character_hash["Subclass"], character_hash["Race"], character_hash["Subrace"], character_hash["Background"], character_hash["Strength"], character_hash["Dexterity"], character_hash["Constitution"], character_hash["Intelligence"], character_hash["Wisdom"], character_hash["Charisma"], character_id)
end