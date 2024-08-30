require_relative 'Chronometre.rb'

##
# Tout observateur de minuteur doit posséder les méthodes updateTemps(tps) et stop().
class Minuteur
    def initialize()
        @tempsMax = 10
        @observers = Array.new
        @chronometre = Chronometre.new
    end
    def changerTempsMax(tps)
        @tempsMax = tps
    end
    def tempsMax()
        @tempsMax
    end
    def ajouterObserver(observer)
        @observers.push(observer)
    end
    def detacherObservateurs()
        @observers.clear
    end
    def start()
        # On ajoute la minuteur comme observateur du chronomètre.
        @chronometre.ajouterObserver(self)
        # Démarrage du chronomètre.
        @chronometre.start
    end
    def stop()
        @chronometre.stop
    end
    # Méthode permettant d'observer le chronomètre.
    def updateTemps(tps)
        # Notifier les observateurs du minuteur d'une modification.
        @observers.each { |o|
            o.updateTemps(@tempsMax - tps)
        }
        # Si le minuteur est à la fin, notifier les observateurs qu'il faut stopper la partie.
        if tps >= @tempsMax
            @chronometre.stop
            @observers.each { |o| o.stop }
        end
    end
end