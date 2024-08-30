module GUIScore
	@@pwd = File.dirname(__FILE__)
	
	def GUIScore.ouvrir(window, container)
		btnRetour = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		btnMenuP = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/account.png"))

		currentMode = "Aventure"
		currentTaille = 6
		currentNumero = nil

########################Scroll###########################################################################################

		scrollZoneTailles = Gtk::ScrolledWindow.new()
		scrollZoneModes = Gtk::ScrolledWindow.new()
		scrollZoneGrille = Gtk::ScrolledWindow.new()

		scrollZone = Gtk::ScrolledWindow.new()
		scrollZone.set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::ALWAYS)
		scrollZoneTailles.set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::ALWAYS)
		scrollZoneModes.set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::ALWAYS)
		scrollZoneGrille.set_policy(Gtk::PolicyType::NEVER,Gtk::PolicyType::ALWAYS)

############################################################################################################################
		@data_store = Gtk::TreeStore.new(Integer,String,String, Integer,Integer)
		#view = Gtk::TreeView.new(@data_store)
		scrollZone.add(view = Gtk::TreeView.new(@data_store))

		loadData(currentMode, currentTaille, currentNumero)
		
		renderer = Gtk::CellRendererText.new

#######################Tree################################################################################################
		col = Gtk::TreeViewColumn.new("Classement", renderer, :text => 0)
		col1 = Gtk::TreeViewColumn.new("Score", renderer, :text => 1)
		col2 = Gtk::TreeViewColumn.new("Détail", renderer, :text => 2)
		col3 = Gtk::TreeViewColumn.new("Taille", renderer, :text => 3)
		col4 = Gtk::TreeViewColumn.new("Numéro", renderer, :text => 4)
		ls7 = Gtk::TreeStore.new(String)
		ls8 = Gtk::TreeStore.new(String)
		ls9 = Gtk::TreeStore.new(String)
		view.set_headers_visible(true)
		view.append_column(col)
		view.append_column(col1)
		view.append_column(col2)
		view.append_column(col3)
		view.append_column(col4)

		hTableLbl = Gtk::Table.new(1,3,true)
		hTableTop = Gtk::Table.new(1,3,true).set_col_spacings(20)
		hTableMid = Gtk::Table.new(1,1,true)
		hTableMid.attach(scrollZone, 0,1,0,1)
		hTableBottom = Gtk::Table.new(1,2,true).set_col_spacings(10)

		############################ scrollZoneModes ##########################################
		cell = ls7.append(nil).set_value(0,"Aventure")
				cell = ls7.append(nil).set_value(0,"Contre-la-Montre")
				cell = ls7.append(nil).set_value(0,"Hardcore")

		# ajout du TreeView à scrollZone
		scrollZoneModes.add(view = Gtk::TreeView.new(ls7))
		# ce sont des cellules de texte
		renderer = Gtk::CellRendererText.new
		# ajoutons la colonne utilis notre renderer
		col = Gtk::TreeViewColumn.new("Mode de Jeu", renderer, :text => 0)
		# on cache le titre
		view.set_headers_visible(false)
		view.append_column(col)

		view.signal_connect('cursor-changed') { |w|
			currentMode = w.selection.selected[0]
			loadData(currentMode, currentTaille, currentNumero)
		}

		# scrollZoneModes.set_size_request(75,110)
		scrollZoneModes.set_size_request(75,78)

############################ scrollZoneTailles ##########################################
		# les données sont stockées dans un TreeStore
		for i in 6..16 do
			cell = ls8.append(nil).set_value(0,i.to_s)
		end

		# ajout du TreeView à scrollZone
		scrollZoneTailles.add(view = Gtk::TreeView.new(ls8))
		# ce sont des cellules de texte
		renderer = Gtk::CellRendererText.new
		# ajoutons la colonne utilis notre renderer
		col = Gtk::TreeViewColumn.new("Taille de la Grille", renderer, :text => 0)
		# on cache le titre
		view.set_headers_visible(false)
		view.append_column(col)

		# scrollZoneTailles.set_size_request(25,5)

		view.signal_connect('cursor-changed') { |w|
			currentTaille = w.selection.selected[0]
			loadData(currentMode, currentTaille, currentNumero)
		}

############################ scrollZoneGrille ##########################################
		# les données sont stockées dans un TreeStore
		cell = ls9.append(nil).set_value(0,"Tous")
		for i in 1..100 do
			cell = ls9.append(nil).set_value(0, i.to_s)
		end

		# ajout du TreeView à scrollZone
		scrollZoneGrille.add(view = Gtk::TreeView.new(ls9))
		# ce sont des cellules de texte
		renderer = Gtk::CellRendererText.new
		# ajoutons la colonne utilis notre renderer
		col = Gtk::TreeViewColumn.new("Numéro", renderer, :text => 0)
		# on cache le titre
		view.set_headers_visible(false)
		view.append_column(col)

		view.signal_connect('cursor-changed') { |w|
			selection = w.selection.selected[0]
			if (selection == "Tous") 
				currentNumero = nil
			else
				currentNumero = w.selection.selected[0]
			end
			
			
			loadData(currentMode, currentTaille, currentNumero)
		}

		# scrollZoneGrille.set_size_request(25,5)

		hTableLbl.attach(Gtk::Label.new("Mode de Jeu").set_name("lblSousTitre"),0,1,0,1)
		hTableTop.attach(scrollZoneModes,0,1,0,1)
		hTableLbl.attach(Gtk::Label.new("Taille de la Grille").set_name("lblSousTitre"),1,2,0,1)
		hTableTop.attach(scrollZoneTailles,1,2,0,1)
		hTableLbl.attach(Gtk::Label.new("Numéro").set_name("lblSousTitre"),2,3,0,1)
		hTableTop.attach(scrollZoneGrille,2,3,0,1)


		hTableBottom.attach(btnRetour,0,3,0,2)
		hTableBottom.attach(btnMenuP,3,6,0,2)



		#Défitnion des tailles des boutons
		# btnRetour.set_size_request(80,50);
		# btnMenuP.set_size_request(80,50);

		#Interaction avec les boutons
		btnRetour.signal_connect('clicked') {GUIMenuPrincipal.ouvrir(window,container)}
		btnMenuP.signal_connect('clicked') {GUIChoixProfil.ouvrir(window,container)}


		#Ajout des widgets ans le container
		container.destroy
		container = Gtk::Box.new(:vertical, 20)
		GUI.ajouterToolbar(window, container, false)

		container.pack_start(Gtk::Label.new("Vos Scores").set_name("lblTitre"), :expand=>false, :fill=>true, :padding=>10)
		container.pack_start(hTableLbl, :expand=>false, :fill=>true, :padding=>0)
		container.pack_start(hTableTop, :expand=>false, :fill=>true, :padding=>0)
		container.pack_start(hTableMid, :expand=>true, :fill=>true, :padding=>0)
		container.pack_start(hTableBottom, :expand=>false, :fill=>true, :padding=>0)
		window.add(container)
		window.show_all
	end

	def GUIScore.loadData(mode, taille, numero)
		dataBaseRef = GestionnaireBaseDeDonnees.getInstance
		listeScores = dataBaseRef.scoreModeTailleNumero(Main.getId, mode, taille, numero)
		i = 0
		lastNumero = -1
		@data_store.clear

		listeScores.each { |j|
			iter = @data_store.append(nil)
			
			if lastNumero == -1 || lastNumero == j["numero_grille"]
				i += 1
			else
				i = 1
			end

			lastNumero = j["numero_grille"]
			iter.values = [i,
				Time.at(j["tempsBrut_score"] + j["malus_score"]).utc.strftime("%H:%M:%S"),
				Time.at(j["malus_score"]).utc.strftime("%H:%M:%S") == "00:00:00" ? "" : Time.at(j["tempsBrut_score"]).utc.strftime("%H:%M:%S") + " + " + Time.at(j["malus_score"]).utc.strftime("%H:%M:%S"),
				j["taille_grille"],
				j["numero_grille"]]
		}
	end

end
