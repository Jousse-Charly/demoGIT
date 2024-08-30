require_relative 'Aide.rb'

class AideArbreUniqueSoluce < Aide
	def AideArbreUniqueSoluce.creer()
		new()
	end

	def initialize()
		@prix = 8
		@malus = 3
		@precision = 1
		@precisionMax = 3
	end

	def aider(grille)
		grille.taille.times do |l|
			grille.taille.times do |c|
				if grille.estArbre?(l,c) then
					nbVide,tentePresente = 0,false
					grille.casesVoisines(grille.plateau(l,c),"o").each { |item|
						nbVide += 1 if item.estVide?
					}
					if nbVide == 1 then
						grille.casesVoisines(grille.plateau(l,c),"o").each { |item|
							if item.l == l then
								voisine = grille.casesVoisines(grille.plateau(l,c),"N").first
								if voisine != nil then tentePresente = true if voisine.estTente? end
								voisine = grille.casesVoisines(grille.plateau(l,c),"S").first
								if voisine != nil then tentePresente = true if voisine.estTente? end
							else
								voisine = grille.casesVoisines(grille.plateau(l,c),"O").first
								if voisine != nil then tentePresente = true if voisine.estTente? end
								voisine = grille.casesVoisines(grille.plateau(l,c),"E").first
								if voisine != nil then tentePresente = true if voisine.estTente? end
							end
						}
						if !tentePresente then
							@titre = "Il est possible qu'un arbre puisse accueillir une tente !" if @precision == 1
							@titre = "Il est possible qu'un arbre puisse accueillir une tente sur la ligne #{l+1}  !" if @precision == 2
							@titre = "Il est possible que l'arbre (#{l+1},#{c+1}) puisse accueillir une tente !" if @precision == 3
							super
							return true
						end
					end
				end
			end
		end
		return false
	end
	
end
