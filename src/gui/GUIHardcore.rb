class GUIHardcore < GUIPartie
	@@pwd = File.dirname(__FILE__)

	def GUIHardcore.ouvrir(taille, numero, window, container)
		new(taille, numero, window, container)
	end
	private_class_method :new

	def initialize(taille, numero, window, container)
		super(taille, numero, window, container)
		@lblMsg.set_text("Aides désactivées, à vous de jouer !")
		@grilleBtnHelp.each { |btnHelp| btnHelp.set_sensitive(false) }
		@tableTop
			.attach(@lblTps.set_name("lblInfo"), 3,4,0,2)
			.attach(Gtk::Label.new("#{taille}x#{taille} - N°#{numero}").set_name("lblInfo"), 4,5,0,2)
		@window.show_all
	end

	def onResetPartie()
		super
		GUIHardcore.ouvrir(@taille, @numero, @window, @container)
	end

	def onRetour()
		GUIOuiNon.ouvrir(@window,"Voulez-vous vraiment quitter la partie ?") do
			onStop
			GUIChoixPartie.ouvrir(@window,@container)
		end
	end

	def onActionPerformed(l,c)
		super
		if @grille.estResolue? then
			onStop
			GUIMessage.ouvrir(@window, "Félicitations, grille résolue !\n\nSCORE : #{Time.at(@calculateurScore.getScore.tempsBrut).utc.strftime("%H:%M:%S")}", Gtk::MessageType::INFO)
			GUIChoixPartie.ouvrir(@window,@container)
		end
	end

end
		