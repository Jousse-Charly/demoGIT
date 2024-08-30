require_relative 'Aide.rb'

class AideTropDeTente < Aide
	def AideTropDeTente.creer()
		new()
	end

	def initialize()
		@prix = 4
		@malus = 1
		@precision = 1
		@precisionMax = 2
	end

	def aider(grille)
		pos = ""
		grille.taille.times do |n|
		    pos = "ligne" if grille.nb(' ','l',n) == 0 && grille.nb('T','l',n) > grille.soluce.nb('T','l',n)
		    pos = "colonne" if grille.nb(' ','c',n) == 0 && grille.nb('T','c',n) > grille.soluce.nb('T','c',n)
			if pos != "" then
			    @titre = "Il y a trop de tente(s) sur une #{pos} !" if @precision == 1
			    @titre = "Il y a trop de tente(s) sur la #{pos} #{n+1} !" if @precision == 2
				super
				return true
			end
		end
        return false
    end

end
