class GUIAventure < GUIPartie
	@@pwd = File.dirname(__FILE__)

	def GUIAventure.ouvrir(taille, numero, window, container, restore)
		new(taille, numero, window, container, restore)
	end
	private_class_method :new

	def initialize(taille, numero, window, container, restore)
		@restore = restore
		super(taille, numero, window, container)
		if @restore
			@lblMsg.set_text(@sauvegarde.msg)
			@lblTps.set_text(Time.at(@chronometre.tempsEcoule).utc.strftime("%H:%M:%S"))
			@lblMalus.set_text("+ "+Time.at(@calculateurScore.getScore.malus).utc.strftime("%H:%M:%S"))
			@checkpoints.eachTitres { |titre|
				@treeStoreCheck.append(nil).set_value(0, "#{titre}")
			}
		end
		btnSave = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/save.png"))
		btnSave.signal_connect('clicked') { onSave }
		@tableTop
			.attach(@lblTps.set_name("lblInfo"), 3,4,1,2)
			.attach(Gtk::Label.new("#{taille}x#{taille} - N°#{numero}").set_name("lblInfo"), 4,5,0,1)
			.attach(@lblMalus.set_name("lblInfo"), 4,5,1,2)
			.attach(@lblCredit, 3,4,0,1)
		@tableBot.resize(1,3)
		@tableBot.attach(btnSave, 2,3,0,1)
		@window.show_all
	end

	# on doit détacher les observeurs que sont des Widgets Gtk, car non suppportés par Marshal
	def onSave()
		@calculateurScore.detacherObservateurs
		@chronometre.detacherObservers
		Sauvegarde.sauvegarder(@calculateurScore, @chronometre, @grille, @coups, @checkpoints, @systemeAide, @gestionnaireSucces, @lblMsg.text)
		@calculateurScore.ajouterObservateur(self)
		@chronometre.ajouterObserver(@calculateurScore)
	end

	def onResetPartie()
		super
		GUIAventure.ouvrir(@taille, @numero, @window, @container, false)
	end

	def initPartie()
		if @restore
			begin
				@sauvegarde = Sauvegarde.restaurer(@taille,@numero)
				@coups = @sauvegarde.coups
				@grille = @sauvegarde.grille
				@checkpoints = @sauvegarde.checkpoints
				@systemeAide = @sauvegarde.systemeAide
				@calculateurScore = @sauvegarde.calculateurScore
				@gestionnaireSucces = @sauvegarde.gestionnaireSucces
			rescue
				GUIMessage.ouvrir(@window, "La sauvegarde est corrompue ou supprimée !\n\nPartie réinitialisée.", Gtk::MessageType::WARNING)
				Sauvegarde.supprimer(@taille,@numero)
				@restore = false
				super
				@gestionnaireSucces = GestionnaireSucces.new(@id_joueur)
			end
		else
			super
			@gestionnaireSucces = GestionnaireSucces.new(@id_joueur)
		end
	end

	def onStart()
		super if !@restore
		@chronometre.reprendre if @restore
	end

	def initTemps()
		if @restore
			@chronometre = @sauvegarde.chronometre
		else
			@chronometre = Chronometre.new
		end
		@chronometre.ajouterObserver(@calculateurScore)
	end

	def onRetour()
		GUIOuiNon.ouvrir(@window,"Voulez-vous vraiment quitter la partie ?") do
			onStop
			GUIChoixAventure.ouvrir(@window,@container)
		end
	end

	def onActionPerformed(l,c)
		if @grille.estTente?(l,c)
			@gestionnaireSucces.tenteSuccessive(l,c) if @grille.estValideCase?(l,c)
			@gestionnaireSucces.resetTenteSuccessive if !@grille.estValideCase?(l,c)
		end
		super
		if @grille.estResolue? then
			onStop
			@bddManager.modifierNiveauJoueur(@id_joueur, @taille, @numero)
			@gestionnaireSucces.finGrille(@taille)
			@gestionnaireSucces.finTenteSuccessive
			Sauvegarde.supprimer(@taille,@numero)
			recompenseTailleGrille = 2*@taille-10
			GUIMessage.ouvrir(@window, "Félicitations, grille résolue !\n\nTemps écoulé : #{Time.at(@calculateurScore.getScore.tempsBrut).utc.strftime("%H:%M:%S")}\nMalus : #{Time.at(@calculateurScore.getScore.malus).utc.strftime("%H:%M:%S")}\nAides utilisées : #{CalculateurScore.nbAideUtilisee}\nRécompenses Taille Grille : #{recompenseTailleGrille}\n\nSCORE : #{Time.at(@calculateurScore.getScore.tempsBrut+@calculateurScore.getScore.malus).utc.strftime("%H:%M:%S")}", Gtk::MessageType::INFO)
			GUIChoixAventure.ouvrir(@window,@container)
			@bddManager.ajouterACagnotte(@id_joueur, recompenseTailleGrille)
		end
	end

end
