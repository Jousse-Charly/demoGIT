module GUIChoixProfil
	@@pwd = File.dirname(__FILE__)

	def GUIChoixProfil.ouvrir(window, container)
		scrollZone = Gtk::ScrolledWindow.new.set_name("profil")
		scrollZone.set_policy(Gtk::PolicyType::NEVER, Gtk::PolicyType::ALWAYS)
		# les données sons stockées dans un TreeStore
		@ls = Gtk::TreeStore.new(String)
		# chargement des profils dans la liste
		refresh
		# ajout du TreeView à scrollZone
		scrollZone.add(view = Gtk::TreeView.new(@ls))
		# ce sont des cellules de texte
		renderer = Gtk::CellRendererText.new
		# ajoutons la colonne utilis notre renderer
		col = Gtk::TreeViewColumn.new("", renderer, :text => 0)
		# on cache le titre
		view.set_headers_visible(false)
		view.append_column(col)

		scrollZone.set_size_request(800,300)			
			
		btnLoad = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/restore.png"))
		btnNew = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/add.png"))
		btnDelete = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/delete.png"))
		
		btnLoad.signal_connect('clicked') {
			id = getIdOfSelectedProfil(view)
			if (id != nil) 
				Main.setId(getIdOfSelectedProfil(view)) #Id du joueur selectionné
				GUIMenuPrincipal.ouvrir(window,container)
			else
				GUIMessage.ouvrir(window, "Vous devez sélectionner un profil !", Gtk::MessageType::INFO)
			end
		}
		btnDelete.signal_connect('clicked') {
			id = getIdOfSelectedProfil(view)
			if id != nil
				GUIOuiNon.ouvrir(window, "Voulez-vous vraiment supprimer ce profil ?") do
					Sauvegarde.supprimerJoueur(id)
					GestionnaireBaseDeDonnees.getInstance.supprimerJoueur(id)
					refresh
				end

			else
				GUIMessage.ouvrir(window, "Vous devez sélectionner un profil !", Gtk::MessageType::INFO)
			end
		}
		btnNew.signal_connect('clicked') {
			GUINouveau.ouvrir(self, window)
		}
		
		container.destroy
		container = Gtk::Box.new(:vertical, 20)
		GUI.ajouterToolbar(window, container, false)
		
		container.pack_start(Gtk::Label.new("Veuillez sélectionner un profil").set_name("lblTitre"), :expand=>false, :fill=>true, :padding=>10)
		container.pack_start scrollZone, expand: true, fill: false, padding: 0
		tableBottom = Gtk::Table.new(1,3,true).set_col_spacings(10)
		tableBottom.attach(btnNew.set_hexpand(true), 0,1,0,1)
		tableBottom.attach(btnDelete.set_hexpand(true), 1,2,0,1)
		tableBottom.attach(btnLoad.set_hexpand(true), 2,3,0,1)
		container.pack_start tableBottom, expand: false, fill: false, padding: 0
		window.add(container)
		window.show_all
	end

	def GUIChoixProfil.getIdOfSelectedProfil(view)
		id = nil
		if view.selection.selected != nil
			@listeProfiles.each { |j|
				id = j["id_joueur"] if j["pseudo_joueur"] == view.selection.selected[0]
			}
		end
		return id
	end

	def GUIChoixProfil.refresh()
		dataBaseRef = GestionnaireBaseDeDonnees.getInstance
		@listeProfiles = dataBaseRef.recupererJoueurs
		@ls.clear
		@listeProfiles.each { |j|
			cell = @ls.append(nil).set_value(0,j["pseudo_joueur"])
		}
	end
	
end