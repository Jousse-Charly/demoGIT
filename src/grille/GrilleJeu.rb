require_relative 'GrilleSoluce.rb'

class GrilleJeu < GrilleSoluce
	attr_reader :soluce

	def GrilleJeu.creer(taille, numero, fichier)
		new(taille,numero,fichier)
	end
	private_class_method :new

	# même initialisation qu'une grille de solution
	# sauf qu'on retire les tentes et le gazon
	def initialize(taille, numero, fichier)
		@soluce = GrilleSoluce.creer(taille,numero,fichier)
		super(taille,numero,fichier)
		@taille.times do |l|
			@taille.times do |c|
				if self.estTente?(l,c) || self.estGazon?(l,c) then
					@plateau[l][c].supprimer
				end
			end
		end
	end

	# place du gazon sur une case
	def engazonner(l, c)
		if !(l>=0 && l<@taille && c>=0 && c<@taille) then
			raise "erreur : coordonnées [#{l}][#{c}] à engazonner invalides ! (0 <-> #{@taille-1})"
		end
		@plateau[l][c].engazonner
		return self
	end

	# supprime une case
	def supprimer(l, c)
		if !(l>=0 && l<@taille && c>=0 && c<@taille) then
			raise "erreur : coordonnées [#{l}][#{c}] à supprimer invalides ! (0 <-> #{@taille-1})"
		end
		@plateau[l][c].supprimer
		return self
	end

	# place une tente sur une case
	def placerTente(l, c)
		if !(l>=0 && l<@taille && c>=0 && c<@taille) then
			raise "erreur : coordonnées [#{l}][#{c}] de la tente à placer invalide ! (0 <-> #{@taille-1})"
		end
		@plateau[l][c].placerTente
		return self	
	end

	# retourne true si la grille de jeu est résolue, faux sinon
	def estResolue?()
		@taille.times do |l|
			@taille.times do |c|
				return false if self.plateau(l,c).type != @soluce.plateau(l,c).type
			end
		end
		return true
	end

	# retourne true si la grille de jeu est identique
	# à celle de la grille passée en paramètre, faux sinon
	def estIdentique?(autreGrille)
		@taille.times do |l|
			@taille.times do |c|
				return false if self.plateau(l,c).type != autreGrille.plateau(l,c).type
			end
		end
		return true
	end

	# retourne true si la case est valide, faux sinon
	def estValideCase?(l, c)
		return self.plateau(l,c).type == @soluce.plateau(l,c).type
	end
	
end