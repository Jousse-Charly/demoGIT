require_relative 'Case.rb'

class GrilleSoluce
	attr_reader :taille, :numero, :fichier

	def GrilleSoluce.creer(taille, numero, fichier)
		new(taille, numero, fichier)
	end
	private_class_method :new

	# taille : dimensions du plateau de jeu.
	# 	=> doit être compris entre 6 et 16.  
	# numero : numero du plateau.
	# 	=> doit être compris entre 1 et 100 pour un choix manuel
	# 	=> 0 pour un choix aléatoire
	# fichier : nom du fichier contenant les grilles
	def initialize(taille, numero, fichier)
		# @taille : dimensions du plateau de jeu.
		# @plateau : matrice de chaques cases du plateau ('A','T','_',' ').

		# vérifie la taille de grille choisie
		if !(taille>=6 && taille<=16) then
			raise "taille de grille invalide ! [6..16]"
		end
		# vérifie le numéro de grille choisie
		if !(numero>=1 && numero<=100) then
			raise "numéro de grille invalide ! [1..100]"
		end 

		@plateau = Array.new
		plateauLigne = Array.new

		@taille = taille
		@numero = numero
		@fichier = fichier

		fichierGrilles = File.new(fichier)
		numLigne = (taille*100 - 6*100) + numero-1
		grilleLigne = fichierGrilles.readlines[numLigne]
		fichierGrilles.close

		grille = grilleLigne.split(';')
		grille.shift # retire nb cols
		grille.shift # retire nb ligs
		grille.pop # retire nb tentes lignes
		
		grille.each { |l|
			ligne = l.split(':') # on sépare la partie grille de la colonne nbTentes
			ligne.first.split(//).each { |item|
				plateauLigne.push(Case.creer(item,@plateau.length,plateauLigne.length))
			}
			@plateau.push(Array.new(plateauLigne))
			plateauLigne.clear
		}
	end

	def to_s()
		str = ""
		@taille.times do |c| str += "#{nb('T','c',c)}" end
		str += "\n#{'-'*@taille}\n"
		@plateau.each { |l|
			l.each {|item| str += item.type}
			str += "\n"
		}
		return str + "\n"
	end

	# retourne une case du plateau
	def plateau(l, c)
		if !(l>=0 && l<@taille && c>=0 && c<@taille) then
			raise "coordonnées plateau invalide ! (0 <-> #{@taille-1})"
		else
			return @plateau[l][c]
		end
	end

	# retourne la liste des cases voisines d'une case en position pos
	def casesVoisines(item, pos)
		iStart = {"a"=>0, "d"=>0, "o"=>1, "NO"=>0, "N"=>1, "NE"=>2, "O"=>3, "E"=>4, "SO"=>5, "S"=>6, "SE"=>7}
		pas = {"a"=>1, "d"=>2, "o"=>2, "NO"=>8, "N"=>8, "NE"=>8, "O"=>8, "E"=>8, "SO"=>8, "S"=>8, "SE"=>8}
		voisines = Array.new
		voisinesFinal = Array.new
		for l in (item.l-1..item.l+1)
			for c in (item.c-1..item.c+1)
				if l >= 0 && l < self.taille && c >= 0 && c < self.taille then
					voisines.push(self.plateau(l,c))
				else
					voisines.push(nil)
				end
			end
		end
		voisines = voisines[0..3].concat(voisines[5..8].reverse)
		for i in (iStart[pos]..7).step(pas[pos])
			voisinesFinal.push(voisines[i])
		end
		voisinesFinal.delete_if { |i| i == nil}
		return voisinesFinal
	end

	# retourne la liste des cases de la ligne l
	def ligne(l)
		raise("numéro ligne incorrect") if !(l>=0 && l<@taille)
		return @plateau[l]
	end

	# retourne la liste des cases de la colonne c
	def colonne(c)
		raise("numéro colonne incorrect") if !(c>=0 && c<@taille)
		return @plateau.transpose[c]
	end	

	# retourne le nombre d'items d'une ligne ou colonne n
	def nb(type, pos, n)
		meth = {"l"=>"ligne", "c"=>"colonne"}
		nbItems = 0
		(self.send(meth[pos], n)).each { |item|
			nbItems += 1 if type == item.type
		}
		return nbItems
	end

	def estArbre?(l, c)
		return self.plateau(l,c).estArbre?
	end

	def estTente?(l, c)
		return self.plateau(l,c).estTente?
	end

	def estGazon?(l, c)
		return self.plateau(l,c).estGazon?
	end

	def estVide?(l, c)
		return self.plateau(l,c).estVide?
	end
	
end
