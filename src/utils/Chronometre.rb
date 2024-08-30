##
# Tout observateur de chronomètre doit posséder la methode updateTemps(tps)
class Chronometre
	def initialize()
		@ecoule = 0
    	@observers = Array.new
	end
    def tempsEcoule()
        return @ecoule
    end
    def ajouterObserver(observer)
        @observers.push(observer)
    end
    def detacherObservers()
        @observers.clear
    end
    # Reprendre le chronomètre après un chargement de partie.
    def reprendre()
        @timer = GLib::Timeout.add(1000) {
            @ecoule += 1
            # Indique aux observeurs de score que le temps a changé.
            @observers.each { |o| o.updateTemps(@ecoule) }
        }
    end
    # Démarrage du chronomètre (On se connecte au signal GTK).
    def start()
        @ecoule = 0
        # Attacher notre methode au signal.
        @timer = GLib::Timeout.add(1000) {
            @ecoule += 1
            # Indique aux observeurs de score que le temps a changé.
            @observers.each { |o| o.updateTemps(@ecoule) }
        }
    end
    # Arrêt du chronomètre (Détachement du signal).
    def stop()
        # Suppression des observateurs.
    	@observers.clear
        # Détacher le signal.
        if @timer != nil
            GLib::Source.remove(@timer)
            @timer = nil
        end
    end
    
    def to_s
        return "ecoule: #{@ecoule}"
    end
    
end