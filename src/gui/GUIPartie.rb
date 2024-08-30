# Classe abstraite d'une partie de jeu. Les spécificités liées aux modes de jeu sont redéfinies dans les classes concrètes.
class GUIPartie
	@@pwd = File.dirname(__FILE__)

	def afficherAide(aide)
		@lblMsg.set_label(aide.titre)
	end

	def GUIPartie.ouvrir(taille, numero, window, container)
		new(taille, numero, window, container)
	end
	private_class_method :new

	def initialize(taille, numero, window, container)
		
		#======[ INITIALISATION ]======#

		@taille = taille
		@numero = numero
		@id_joueur = Main.getId
		@window = window
		@container = container
		@fichier = "#{@@pwd}/../../data/GrillesTriees.txt"

		initPartie
		@bddManager = GestionnaireBaseDeDonnees.getInstance
		@calculateurScore.ajouterObservateur(self)
		initTemps

		typeToImg = {"A"=>"#{@@pwd}/../../img/tree.png", "T"=>"#{@@pwd}/../../img/tent.png", "_"=>"#{@@pwd}/../../img/grass.png", " "=>"#{@@pwd}/../../img/empty.png"}
		typeSuiv = {" "=>"_", "_"=>"T", "T"=>" "}
		action = {" "=>"supprimer", "_"=>"engazonner", "T"=>"placerTente"}


		#======[ WIDGETS ]======#

		# conteneurs des boutons de la @grille de jeu, nb tentes et d'aides
		grilleBtnCol = Array.new
		grilleBtnLig = Array.new
		@grilleBtnHelp = Array.new
		grilleBtn = Array.new

		# label du message d'aide
		@lblMsg = Gtk::Label.new("À vous de jouer !").set_line_wrap(true)

		# label du crédit du joueur
		@lblCredit = Gtk::Label.new(@bddManager.recupererCagnotteJoueur(@id_joueur).to_s).set_name("lblCredit")

		# label du temps écoulé
		@lblTps = Gtk::Label.new(Time.at(0).utc.strftime("%H:%M:%S"))

		# label du malus
		@lblMalus = Gtk::Label.new("+ 00:00:00")

		# boutons du nombre de tentes
		taille.times do |i|
			grilleBtnCol.push(Gtk::Button.new(label: "#{@grille.soluce.nb('T','c',i)}")
				.set_name("btnNbTente"))
			grilleBtnLig.push(Gtk::Button.new(label: "#{@grille.soluce.nb('T','l',i)}")
				.set_name("btnNbTente"))
		end

		# boutons de la grille de jeu
		taille.times do |l|
			taille.times do |c|
				grilleBtn.push(Gtk::Button.new
					.set_hexpand(true).set_vexpand(true)
					.set_image(Gtk::Image.new(file: typeToImg[@grille.plateau(l,c).type])))
			end
		end

		# boutons d'aide
		4.times do
			@grilleBtnHelp.push(Gtk::Button.new
				.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/help.png")))
		end

		# boutons de contrôle des coups et checkpoints
		btnCoupPrec = Gtk::Button.new.set_hexpand(true)
			.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		btnCoupSuiv = Gtk::Button.new.set_hexpand(true)
			.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/next.png"))
		btnResetPartie = Gtk::Button.new.set_hexpand(true)
			.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/reset.png"))
		btnSaveCheckpoint = Gtk::Button.new.set_hexpand(true)
			.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/save.png"))

		# boutons de navigation des fenêtres
		btnRetour = Gtk::Button.new
			.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		btnPrincipal = Gtk::Button.new
			.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/home.png"))

		# liste des checkpoints
        scrollZone = Gtk::ScrolledWindow.new()
		scrollZone.set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::ALWAYS)
		# les données sons stockées dans un TreeStore
		@treeStoreCheck = Gtk::TreeStore.new(String)
		# ajout du TreeView à scrollZone
		scrollZone.add(view = Gtk::TreeView.new(@treeStoreCheck).set_name("scrollZone"))
		# ce sont des cellules de texte
		renderer = Gtk::CellRendererText.new
		# ajoutons la colonne utilis notre renderer
		col = Gtk::TreeViewColumn.new("", renderer, :text => 0)
		# on cache le titre
		view.set_headers_visible(false)
		view.append_column(col)


		#======[ SIGNAUX ]======#

		# restaure l'état de la grille du checkpoint cliqué
		view.signal_connect('cursor-changed') { |w|
			@grille = @coups.restoreCoup(@checkpoints.indiceCoup(w.selection.selected.path.indices[0]))
			taille.times do |l|
				taille.times do |c|
					img = Gtk::Image.new(file: typeToImg[@grille.plateau(l,c).type])
					grilleBtn[l*taille+c].set_image(img)
				end
			end
		}

		# engazonne la ligne/colonne cliquée et enregistre le coup
		taille.times do |i|	

			grilleBtnCol[i].signal_connect('clicked') {
				if @grille.nb(' ','c',i) > 0 then
					taille.times do |j|
						if @grille.estVide?(j,i) then
							@grille.engazonner(j,i)
							img = Gtk::Image.new(file: "#{@@pwd}/../../img/grass.png")
							grilleBtn[j*taille+i].set_image(img)
							onActionPerformed(j,i)
						end
					end
					@coups.addCoup(@grille)
				end
			}

			grilleBtnLig[i].signal_connect('clicked') {
				if @grille.nb(' ','l',i) > 0 then					
					taille.times do |j|
						if @grille.estVide?(i,j) then
							@grille.engazonner(i,j)
							img = Gtk::Image.new(file: "#{@@pwd}/../../img/grass.png")
							grilleBtn[i*taille+j].set_image(img)
							onActionPerformed(j,i)
						end
					end
					@coups.addCoup(@grille)
				end
			}
		end

		# met à jour le type de la case cliquée et enregistre le coup
		taille.times do |l|
			taille.times do |c|
				grilleBtn[l*taille+c].signal_connect('clicked') {
					if !@grille.estArbre?(l,c) then
						@grille.send(action[typeSuiv[@grille.plateau(l,c).type]],l,c)
						img = Gtk::Image.new(file: typeToImg[@grille.plateau(l,c).type])
						grilleBtn[l*taille+c].set_image(img)
						@coups.addCoup(@grille)
						onActionPerformed(l,c)
					end
				}
			end
		end

		# demande de l'aide
		@grilleBtnHelp.each { |btnHelp|
			btnHelp.signal_connect('clicked') {
				GUIPaiementAide.ouvrir(self, @window, @systemeAide, @calculateurScore, @grille)
			}
		}
		
		# réinitialise la partie
		btnResetPartie.signal_connect('clicked') { onResetPartie }

		# enregistre le checkpoint
        btnSaveCheckpoint.signal_connect('clicked') {
        	@treeStoreCheck.append(nil).set_value(0, "#{@lblTps.text}")
        	@checkpoints.add("#{@lblTps.text}", @coups.indiceCourant)
        }

        # restaure l'état de la grille du coup précédent
        btnCoupPrec.signal_connect('clicked') {
        	@grille = @coups.restoreCoupPrec
			taille.times do |l|
				taille.times do |c|
					img = Gtk::Image.new(file: typeToImg[@grille.plateau(l,c).type])
					grilleBtn[l*taille+c].set_image(img)
				end
			end
        }

        # restaure l'état de la grille du coup suivant
        btnCoupSuiv.signal_connect('clicked') {
        	@grille = @coups.restoreCoupSuiv
			taille.times do |l|
				taille.times do |c|
					img = Gtk::Image.new(file: typeToImg[@grille.plateau(l,c).type])
					grilleBtn[l*taille+c].set_image(img)
				end
			end
        }

        # naviguation dans les fenêtres
        btnRetour.signal_connect('clicked') { onRetour }
        btnPrincipal.signal_connect('clicked') { onPrincipal }


		#======[ LAYOUT ]======#

		@container.destroy
		@container = Gtk::Box.new(:vertical, 20)
		GUI.ajouterToolbar(@window, @container, true)
		
		@tableTop = Gtk::Table.new(2,5,true).set_col_spacings(10)
		tableMid = Gtk::Table.new(1,5,true).set_col_spacings(10)
			tableGrille = Gtk::Table.new(taille+2,taille+2,true)
				.set_col_spacings(3).set_row_spacings(3)
			vBoxMidRight = Gtk::Box.new(:vertical, 3)
				tableCrtl = Gtk::Table.new(1,4,true).set_col_spacings(3)
				tableLst = Gtk::Table.new(1,1,true)
		@tableBot = Gtk::Table.new(1,2,true).set_col_spacings(10)

		@tableTop
			.attach(Gtk::ScrolledWindow.new.add(@lblMsg.set_name("lblInfo")), 0,3,0,2)

		taille.times do |l|			
			tableGrille
				.attach(grilleBtnLig[l], 0,1,l+1,l+2)
				.attach(grilleBtnCol[l], l+1,l+2,0,1)
				.attach(Gtk::Button.new(label: "#{l+1}"), taille+1,taille+2,l+1,l+2)
				.attach(Gtk::Button.new(label: "#{l+1}"), l+1,l+2,taille+1,taille+2)
			taille.times do |c|
		    	tableGrille.attach(grilleBtn[l*taille+c],c+1,c+2,l+1,l+2)
		  	end
		end
		
		tableGrille
			.attach(@grilleBtnHelp[0], 0,1,0,1)
			.attach(@grilleBtnHelp[1], taille+1,taille+2,0,1)
			.attach(@grilleBtnHelp[2], 0,1,taille+1,taille+2)
			.attach(@grilleBtnHelp[3], taille+1,taille+2,taille+1,taille+2)
		
		vBoxMidRight
			.add(tableCrtl
				.attach(btnCoupPrec, 0,1,0,1)
				.attach(btnCoupSuiv, 1,2,0,1)
				.attach(btnSaveCheckpoint, 2,3,0,1)
				.attach(btnResetPartie, 3,4,0,1))
			.add(tableLst
				.attach(scrollZone.set_hexpand(true).set_vexpand(true), 0,1,0,1))

		tableMid
			.attach(tableGrille,0,3,0,1)
			.attach(vBoxMidRight,3,5,0,1)

		@tableBot
			.attach(btnRetour,0,1,0,1)
			.attach(btnPrincipal,1,2,0,1)

		@container.add(@tableTop)
			.add(tableMid)
			.add(@tableBot)
		
		@window.add(@container)

		onStart
	end


	#======[ ACTIONS ]======#

	def initPartie()
		@grille = GrilleJeu.creer(@taille, @numero, @fichier)
		@coups = HistoriqueCoups.creer(@grille)
		@checkpoints = Checkpoints.new
		@systemeAide = GestionnaireAide.creer(@grille)
		@calculateurScore = CalculateurScore.new
	end

	def onResetPartie()
		onStop
	end

	# initialisation du chronomètre (minuteur en Contre-la-Montre)
	def initTemps()
		@chronometre = Chronometre.new
		@chronometre.ajouterObserver(@calculateurScore)
	end

	# lance le chronomètre (minuteur en Contre-la-Montre)
	def onStart()
		@chronometre.start
	end

	# stope le chronomètre (minuteur en Contre-la-Montre)
	def onStop()
		@chronometre.stop
		@calculateurScore.detacherObservateurs
	end

	# naviguation entres les fenêtres
	def onRetour()
		# implémenté par les parties de jeu concrètes
	end

	def onPrincipal()
		GUIOuiNon.ouvrir(@window,"Voulez-vous vraiment quitter la partie ?") do
			onStop
			GUIMenuPrincipal.ouvrir(@window,@container)
		end
	end

	# action sur la grille de jeu
	def onActionPerformed(l,c)
		if @grille.estResolue? then
			@bddManager.ajouterScore(
				@id_joueur,
				Main.getMode,
				@calculateurScore.getScore.tempsBrut,
				@calculateurScore.getScore.malus,
				@taille,
				@numero)
		end
	end

	# met à jour le label du crédit
	def updateCredit(credit)
		@lblCredit.set_label(credit.to_s)
	end

	# méthode des observateurs de score
	def updateScore(tps)
		if (@lblTps != nil)
			@lblTps.set_label(tps.tempsBrut_to_s)
		end

		if (@lblMalus!= nil) 
			@lblMalus.set_label("+ "+tps.malus_to_s)
		end
	end

end