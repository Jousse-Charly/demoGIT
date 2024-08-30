require_relative 'Aide.rb'

class AideVideAutourTente < Aide
	def AideVideAutourTente.creer()
		new()
	end

	def initialize()
		@prix = 4
		@malus = 1
		@precision = 1
		@precisionMax = 3
	end

	def aider(grille)
		pos = ""
		grille.taille.times do |l|
			grille.taille.times do |c|
				if grille.estTente?(l,c) then
					grille.casesVoisines(grille.plateau(l,c),"a").each { |item|
						if item.estVide?() then
							@titre = "Il y a une case vide autour d'une tente !" if @precision == 1
							@titre = "Il y a une case vide sur la ligne #{item.l+1} autour d'une tente !" if @precision == 2
							@titre = "La case (#{item.l+1},#{item.c+1}) est vide alors qu'elle se trouve autour d'une tente !" if @precision == 3
							super
							return true
						end	
					}
				end
			end
		end
		return false
	end

end
