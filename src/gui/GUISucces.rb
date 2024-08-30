module GUISucces
	@@pwd = File.dirname(__FILE__)
	
	def GUISucces.ouvrir(window, container)
		scrollZone = Gtk::ScrolledWindow.new
		scrollZone.set_policy(Gtk::PolicyType::NEVER, Gtk::PolicyType::ALWAYS)
		# les données sons stockées dans un TreeStore
		@ls = Gtk::TreeStore.new(String, String, String)
		# chargement des profiles dans la liste
		refresh()
		# ajout du TreeView à scrollZone
		scrollZone.add(view = Gtk::TreeView.new(@ls))
		# ce sont des cellules de texte
		renderer = Gtk::CellRendererText.new
		# ajoutons la colonne utilis notre renderer
		col1 = Gtk::TreeViewColumn.new("Statut", renderer, :text => 0)
		col = Gtk::TreeViewColumn.new("Succès", renderer, :text => 1)
		col2 = Gtk::TreeViewColumn.new("Récompense", renderer, :text => 2)
		# on cache le titre
		#view.set_headers_visible(false)
		view.append_column(col1)
		view.append_column(col)
		view.append_column(col2)

		scrollZone.set_size_request(200,200)

		btnRetour = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		btnPrincipal = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/account.png"))

		btnRetour.signal_connect('clicked') {GUIMenuPrincipal.ouvrir(window,container)}
		btnPrincipal.signal_connect('clicked') {GUIChoixProfil.ouvrir(window,container)}

		container.destroy
		container = Gtk::Box.new(:vertical, 20)
		GUI.ajouterToolbar(window, container, false)
		container.pack_start(Gtk::Label.new("Vos Succès").set_name("lblTitre"), :expand=>false, :fill=>true, :padding=>10)
		container.pack_start(scrollZone, :expand=>true, :fill=>true, :padding=>0)
		tableBottom = Gtk::Table.new(1,2,true).set_col_spacings(10)
		tableBottom.attach(btnRetour, 0,1,0,1)
		tableBottom.attach(btnPrincipal, 1,2,0,1)
		container.pack_start(tableBottom, :expand=>false, :fill=>true, :padding=>0)
		window.add(container)
		window.show_all
	end

	def GUISucces.refresh()
		dataBaseRef = GestionnaireBaseDeDonnees.getInstance
		@listeSucces = dataBaseRef.recupererSucces(Main.getId)
		@ls.clear

		@listeSucces.each { |j|
			iter = @ls.append(nil)
			recompense = j["recompense_succes"].to_s

			if j["recompense_succes"] == -1
				case j["intitule_succes"]
					when "Plusieurs tentes correctes placées consécutivement"
						recompense = "Nombre de tente" 
					when "Finir une grille sans aide"
						recompense = "Taille de la grille"
					when "Débloquer un niveau sans passer par le crédit"
						recompense = "Taille du niveau"
					else
						recompense = "n"
				end
			end

			iter.values = [j["estDebloque_succes"] == 1 ? "Débloqué" : "Verrouillé",j["intitule_succes"], recompense]
		}
	end

end
