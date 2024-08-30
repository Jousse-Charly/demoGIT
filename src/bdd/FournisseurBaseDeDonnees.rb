require 'sqlite3'

# Classe permettant de gérer le donneur de base de données
class FournisseurBaseDeDonnees
    @@pwd = File.dirname(__FILE__)
    @@db = nil

    # Singleton permettant de retourner une seule instance de la base de données
    def self.getInstance()
        if @@db == nil
            @@db = SQLite3::Database.open "#{@@pwd}/../../data/treeAndTents.db"
            self.executerSQL("PRAGMA foreign_keys = ON")
        end
        return @@db
    end

    # Méthode permettant d'éxécuter une requête SQL et de retourner l'id de type INSERT pour retourner par la suite l'identifiant de l'élément inséré.
    def self.executerInsertSQL(sql)
        self.executerSQL(sql)
        return self.getInstance.last_insert_row_id
    end

    # Méthode permettant d'éxécuter une requête SQL.
    def self.executerSQL(sql)
        self.getInstance.execute sql
    end

    # Méthode permettant de fermer la base de données
    def self.fermerBaseDeDonnees()
        self.getInstance.close
    end

end
