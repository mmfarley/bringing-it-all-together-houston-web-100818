require 'pry'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        self.name = name
        self.breed = breed
    end

    def self.create_table
        sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql) 
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE dogs;')
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
        #binding.pry
        dog_instance = Dog.new(id: id, name: self.name, breed: self.breed)
        dog_instance
    end

    def self.create(attr_hash)
        new_dog_object = self.new(id: attr_hash[:id], name: attr_hash[:name], breed: attr_hash[:breed])
        new_dog_object.save
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        results = DB[:conn].execute(sql, id)[0]
        self.new(id: results[0], name: results[1], breed: results[2])
    end

    def self.find_or_create_by(attr_hash)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])
        if !dog.empty?
            dog_stuff = dog[0]
            dog = self.new(id: dog_stuff[0], name: dog_stuff[1], breed: dog_stuff[2])
        else
            dog = self.create(id: attr_hash[:id], name: attr_hash[:name], breed: attr_hash[:breed])
        end
        dog
    end

    def self.new_from_db(data_array)
        self.new(id: data_array[0], name: data_array[1], breed: data_array[2])
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        results = DB[:conn].execute(sql, name)[0]
        self.new(id: results[0], name: results[1], breed: results[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end