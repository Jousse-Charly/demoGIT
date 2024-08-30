class GUIVsMontre < GUIPartie
	@@pwd = File.dirname(__FILE__)

	def GUIVsMontre.ouvrir(taille, numero, window, container)
		new(taille, numero, window, container)
	end
	private_class_method :new

	def initialize(taille, numero, window, container)
		super(taille, numero, window, container)
		@lblTps.set_text(Time.at(@tpsMax).utc.strftime("%H:%M:%S"))
		@tableTop
			.attach(@lblTps.set_name("lblInfo"), 3,4,0,2)
			.attach(Gtk::Label.new("#{taille}x#{taille} - N°#{numero}").set_name("lblInfo"), 4,5,0,1)
			.attach(@lblMalus.set_name("lblInfo"), 4,5,1,2)
		@window.show_all
	end

	def onResetPartie()
		super
		GUIVsMontre.ouvrir(@taille, @numero, @window, @container)
	end

	def initTemps()
		@tpsMax = @bddManager.recupererTempsMax(@taille)
		@minuteur = Minuteur.new
		@minuteur.ajouterObserver(@calculateurScore)
		@minuteur.changerTempsMax(@tpsMax)
	end

	def onStart()
		@minuteur.start
	end

	# au 'stop' envoyé par le minuteur
	def stop()
		onStop
		tpsMalus = @calculateurScore.getScore.malus
		GUIMessage.ouvrir(@window, "Dommage, grille non résolue avant le temps imparti !\n\nTemps imparti : #{Time.at(@tpsMax).utc.strftime("%H:%M:%S")}\nMalus : #{Time.at(tpsMalus).utc.strftime("%H:%M:%S")}\nAides utilisées : #{CalculateurScore.nbAideUtilisee}", Gtk::MessageType::WARNING)
		GUIChoixVsMontre.ouvrir(@window,@container)
	end

	def onStop()
		@minuteur.stop
		@calculateurScore.detacherObservateurs
	end

	def onRetour()
		GUIOuiNon.ouvrir(@window,"Voulez-vous vraiment quitter la partie ?") do
			onStop
			GUIChoixVsMontre.ouvrir(@window,@container)
		end
	end

	def onActionPerformed(l,c)
		if @grille.estResolue?
			onStop
			tpsEcoule = @tpsMax - @calculateurScore.getScore.tempsBrut
			tpsMalus = @calculateurScore.getScore.malus
			if @tpsMax >= (tpsEcoule + tpsMalus)
				@bddManager.ajouterScore(
					@id_joueur,
					Main.getMode,
					tpsEcoule,
					tpsMalus,
					@taille,
					@numero)
				GUIMessage.ouvrir(@window, "Félicitations, grille résolue avant le temps imparti !\n\nTemps imparti : #{Time.at(@tpsMax).utc.strftime("%H:%M:%S")}\nTemps écoulé : #{Time.at(tpsEcoule).utc.strftime("%H:%M:%S")}\nMalus : #{Time.at(tpsMalus).utc.strftime("%H:%M:%S")}\nAides utilisées : #{CalculateurScore.nbAideUtilisee}\n\nSCORE : #{Time.at(tpsEcoule+tpsMalus).utc.strftime("%H:%M:%S")}", Gtk::MessageType::INFO)
			else
				GUIMessage.ouvrir(@window, "Dommage, trop de malus pour respecter le temps imparti !\n\nTemps imparti : #{Time.at(@tpsMax).utc.strftime("%H:%M:%S")}\nTemps écoulé : #{Time.at(tpsEcoule).utc.strftime("%H:%M:%S")}\nMalus : #{Time.at(tpsMalus).utc.strftime("%H:%M:%S")}\nAides utilisées : #{CalculateurScore.nbAideUtilisee}", Gtk::MessageType::WARNING)
			end
			GUIChoixVsMontre.ouvrir(@window,@container)
		end
	end

end