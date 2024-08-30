require_relative 'Aide.rb'

class AideResteQueGazon < Aide
	def AideResteQueGazon.creer()
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
			pos = "ligne" if grille.nb('T','l',n) == grille.soluce.nb('T','l',n) && grille.nb(' ','l',n) > 0
			pos = "colonne" if grille.nb('T','c',n) == grille.soluce.nb('T','c',n) && grille.nb(' ','c',n) > 0
			if pos != "" then
				@titre = "Une #{pos} a toutes ses tentes, il ne reste plus qu'à placer du gazon !" if @precision == 1
				@titre = "La #{pos} #{n+1} a toutes ses tentes, il ne reste plus qu'à placer du gazon !" if @precision == 2
				super
				return true
			end
		end
		return false
	end

end
