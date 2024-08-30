require_relative 'Aide.rb'

class AideTenteDiagonaleAbr < Aide
	def AideTenteDiagonaleAbr.creer()
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
					abrDiag,abrOrth = false,false
					grille.casesVoisines(grille.plateau(l,c),"d").each { |vDiag|
						abrDiag = true if vDiag.estArbre?
					}
					grille.casesVoisines(grille.plateau(l,c),"o").each { |vOrth|
						abrOrth = true if vOrth.estArbre?
					}
					if abrDiag == true && abrOrth == false then
						@titre = "Une tente est placée en diagonale d’un arbre, or elle ne peut l’être qu’à l’horizontale ou la verticale !" if @precision == 1
						@titre = "Une tente est placée en diagonale d’un arbre sur la ligne #{l+1}, or elle ne peut l’être qu’à l’horizontale ou la verticale !" if @precision == 2
						@titre = "La tente (#{l+1},#{c+1}) est placée en diagonale d’un arbre, or elle ne peut l’être qu’à l’horizontale ou la verticale !" if @precision == 3
						super
						return true
					end

				end
			end
		end
		return false
	end

end