require_relative 'Aide.rb'

class AideResteQueTente < Aide
	def AideResteQueTente.creer()
		new()
	end

	def initialize()
		@prix = 4
		@malus = 1
		@precision = 1
		@precisionMax = 2
	end

	def aider(grille)
		grille.taille.times do |n|
			pos = ""
			pos = "ligne" if (nb = grille.nb(' ','l',n)) == (grille.soluce.nb('T','l',n) - grille.nb('T','l',n)) && nb > 0	
			pos = "colonne" if (nb = grille.nb(' ','c',n)) == (grille.soluce.nb('T','c',n) - grille.nb('T','c',n)) && nb > 0
			if pos != "" then
				@titre = "Une #{pos} a tous ses gazons, il ne reste plus qu'à placer des tentes !" if @precision == 1
				@titre = "La #{pos} #{n+1} a tous ses gazons, il ne reste plus qu'à placer des tentes !" if @precision == 2
				super
				return true
			end
		end
		return false
	end

end
