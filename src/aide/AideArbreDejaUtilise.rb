require_relative 'Aide.rb'

class AideArbreDejaUtilise < Aide
	def AideArbreDejaUtilise.creer()
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
				if grille.estArbre?(l,c)
					abr = grille.plateau(l,c)
					nbTentesVoisAttendues,nbTentesVoisActuel = 0,0
					nbGazonsVoisAttendus,nbGazonsVoisActuel = 0,0
					grille.casesVoisines(abr,"o").each { |voisAbr|
						nbTentesVoisActuel += 1 if voisAbr.estTente?
						nbGazonsVoisActuel += 1 if voisAbr.estGazon?
					}
					grille.soluce.casesVoisines(abr,"o").each { |voisAbr|
						nbTentesVoisAttendues += 1 if voisAbr.estTente?
						nbGazonsVoisAttendus += 1 if voisAbr.estGazon?
					}
					if nbTentesVoisAttendues == nbTentesVoisActuel && nbGazonsVoisAttendus > nbGazonsVoisActuel
						@titre = "Un arbre est déjà utilisé, ses cases adjacentes qui ne pouvaient que lui être associées peuvent donc être engazonnées !" if @precision == 1
						@titre = "Un arbre sur la ligne #{l+1} est déjà utilisé, ses cases adjacentes qui ne pouvaient que lui être associées peuvent donc être engazonnées !" if @precision == 2
						@titre = "L'arbre (#{l+1},#{c+1}) est déjà utilisé, ses cases adjacentes qui ne pouvaient que lui être associées peuvent donc être engazonnées !" if @precision == 3
						super
						return true
					end
				end
			end
		end
		return false
	end

	# ANCIENNE VERSION FAUSSE
	#
	# def aider(grille)
	# 	grille.taille.times do |l|
	# 		grille.taille.times do |c|
	# 			if grille.estArbre?(l,c) then
	# 				nbTentes = 0
	# 				grille.casesVoisines(grille.plateau(l,c),"o").each { |voisAbr|
	# 					nbTentes += 1 if voisAbr.estTente?
	# 				}
	# 				if nbTentes >= 1 then
	# 					grille.casesVoisines(grille.plateau(l,c),"o").each { |voisAbr|
	# 						if voisAbr.estVide? then
	# 							nbAbr = 0
	# 							grille.casesVoisines(voisAbr,"o").each { |voisVide|
	# 								nbAbr += 1 if voisVide.estArbre?
	# 							}
	# 							if nbAbr == 1 then
	# 								@titre = "Un arbre est déjà utilisé, ses cases adjacentes qui ne pouvaient que lui être associées peuvent donc être engazonnées !" if @precision == 1
	# 								@titre = "Un arbre sur la ligne #{l+1} est déjà utilisé, ses cases adjacentes qui ne pouvaient que lui être associées peuvent donc être engazonnées !" if @precision == 2
	# 								@titre = "L'arbre (#{l+1},#{c+1}) est déjà utilisé, ses cases adjacentes qui ne pouvaient que lui être associées peuvent donc être engazonnées !" if @precision == 3
	# 								super
	# 								return true
	# 							end
	# 						end
	# 					}
	# 				end
	# 			end
	# 		end
	# 	end
	# 	return false
	# end
	
end
