class Sauvegarde
	private_class_method :new
	@@pwd = File.dirname(__FILE__)
	attr_reader :calculateurScore, :chronometre, :grille, :coups, :checkpoints, :systemeAide, :gestionnaireSucces, :msg

	# supprime tous les fichiers de sauvegarde d'un joueur
	def Sauvegarde.supprimerJoueur(idJoueur)
		sauvegardes = GestionnaireBaseDeDonnees.getInstance.sauvegardesJoueur(idJoueur)
		sauvegardes.each { |sauvegarde|
			File.delete("#{@@pwd}/../../data/#{sauvegarde["filename"]}") if File.exist?("#{@@pwd}/../../data/#{sauvegarde["filename"]}")
		}
	end

	# supprime une sauvegarde (référence dans la bdd et fichier de sauvegarde)
	def Sauvegarde.supprimer(taille, numero)
		filename = "#{Main.getId}-#{taille}-#{numero}.txt"
		File.delete("#{@@pwd}/../../data/#{filename}") if File.exist?("#{@@pwd}/../../data/#{filename}")
		GestionnaireBaseDeDonnees.getInstance.supprimerSauvegarde(Main.getId, taille, numero)
	end

	# charge une sauvegarde depuis son fichier
	def Sauvegarde.restaurer(taille, numero)
		filename = "#{Main.getId}-#{taille}-#{numero}.txt"
		File.open("#{@@pwd}/../../data/#{filename}",'rb') { |file| return Marshal.load(file.read) }
	end

	# enregistre une sauvegarde dans un fichier ainsi que sa référence dans la bdd
	def Sauvegarde.sauvegarder(calculateurScore, chronometre, grille, coups, checkpoints, systemeAide, gestionnaireSucces, msg)
		new(calculateurScore, chronometre, grille, coups, checkpoints, systemeAide, gestionnaireSucces, msg)
	end

	def initialize(calculateurScore, chronometre, grille, coups, checkpoints, systemeAide, gestionnaireSucces, msg)
		@grille = grille
		@coups = coups
		@checkpoints = checkpoints 
		@systemeAide = systemeAide
		@msg = msg
		@calculateurScore = calculateurScore
		@gestionnaireSucces = gestionnaireSucces
		@chronometre = chronometre
		
		@filename = "#{Main.getId}-#{@grille.taille}-#{@grille.numero}.txt"
		File.open("#{@@pwd}/../../data/#{@filename}",'wb') { |file| file.write(Marshal.dump(self)) }
		GestionnaireBaseDeDonnees.getInstance.ajouterSauvegarde(Main.getId, @grille.taille, @grille.numero, @filename)
	end

end