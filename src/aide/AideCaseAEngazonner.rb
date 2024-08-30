require_relative 'Aide.rb'

class AideCaseAEngazonner < Aide
	def AideCaseAEngazonner.creer()
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
				if grille.estVide?(l,c) then
					videAEngazonner =  true
					grille.casesVoisines(grille.plateau(l,c),"o").each { |item|
						videAEngazonner = false if item.estArbre?
					}
					if videAEngazonner == true
						@titre = "Une case vide n'est pas à côté d'un arbre, elle peut donc être engazonnée." if @precision == 1
						@titre = "Une case vide sur la ligne #{l+1} n'est pas à côté d'un arbre, elle peut donc être engazonnée." if @precision == 2
						@titre = "La case vide (#{l+1},#{c+1}) n'est pas à côté d'un arbre, elle peut donc être engazonnée." if @precision == 3
						super
						return true
					end
				end
			end
		end
		return false
	end

end
