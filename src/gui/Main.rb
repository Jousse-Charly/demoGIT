require_relative'GUI.rb'

class Main
    def self.setId(id_joueur)
        @id_joueur = id_joueur
    end

    def self.getId()
        return @id_joueur
    end
    def self.setMode(mode)
        @mode = mode
    end

    def self.getMode()
        return @mode
    end
end

gui = GUI.lancer
