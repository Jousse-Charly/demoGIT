require_relative 'Aide.rb'

class AideTenteAucunArbre < Aide
	def AideTenteAucunArbre.creer()
		new()
	end

	def initialize()
		@prix = 6
		@malus = 2
		@precision = 1
		@precisionMax = 3
	end

	def aider(grille)
		grille.taille.times do |l|
			grille.taille.times do |c|
				if grille.estTente?(l,c) then
					tenteAucunAbr =  true
					grille.casesVoisines(grille.plateau(l,c),"o").each { |item|
						tenteAucunAbr = false if item.estArbre?
					}
					if tenteAucunAbr == true
						@titre = "Une tente n'est associée à aucun arbre ! la case peut donc être engazonnée." if @precision == 1
						@titre = "Une tente sur la ligne #{l+1} n'est associée à aucun arbre ! la case peut donc être engazonnée." if @precision == 2
						@titre = "La tente (#{l+1},#{c+1}) n'est associée à aucun arbre ! la case peut donc être engazonnée." if @precision == 3
						super
						return true
					end
				end
			end
		end
		return false
	end

end
