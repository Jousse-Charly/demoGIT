require_relative 'Score.rb'

##
# Tout observateur de minuteur doit posséder la méthode updateScore(score)
class CalculateurScore
    # @malus Total des malus de la partie en cours
    # @observeurs Observateur du calculateur de score
    # @temps Temps de la partie en cours

    @@nbAideUtilisee = 0 # Total des aides utilisées pour la partie en cours

    def initialize()
        @malus = 0
        @temps = 0
        @@nbAideUtilisee = 0
        @observeurs = Array.new
    end

    # Méthode permettant d'ajouter un observateur au calculateur de score, celui-ci devra contenir une méthode updateScore(score)
    def ajouterObservateur(observateur)
        @observeurs.push(observateur)
    end

    def detacherObservateurs()
        @observeurs.clear
    end

    # Méthode permettant d'indiquer aux observeurs de score que ce dernier a changé.
    def updateScore()
        @observeurs.each { |o| o.updateScore(getScore) }
    end
    
    # Méthode appelée par la GUI quand l'utilisateur choisit de payer l'aide par malus.
    def updateMalus(malus)
        updateScore
        @malus += malus
    end

    # Méthode appelée par l'observé du calculateur de score (à l'heure actuelle le chronomètre).
    def updateTemps(tps)
        @temps = tps
        updateScore
    end

    # Méthode permettant de récuperer le nombre d'aides utilisées pour la partie en cours
    def self.nbAideUtilisee()
        @@nbAideUtilisee
    end

    def updateNbAideUtilisee()
        @@nbAideUtilisee += 1
    end

    # Méthode permettant de stopper la partie dans le cas de l'utilisation d'un chronomètre.
    def stop()
        @observeurs.each { |o| o.stop }
    end

    # Méthode permettant de récuperer le score calculé
    def getScore()
        return Score.new(Main.getMode, @temps, @malus)
    end

    def to_s
        return "malus: #{@malus}, temps: #{@temps}, nbAides: #{@@nbAideUtilisee}"
    end

end

