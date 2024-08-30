class GUIChoixPartie
    @@pwd = File.dirname(__FILE__)

    def GUIChoixPartie.ouvrir(window, container)
    	new(window, container)
    end
    private_class_method :new

    def initialize(window, container)
        @bdd = GestionnaireBaseDeDonnees.getInstance
        @window = window
        @container = container
		@grilleParTaille = [] # liste des grilles {taille, dimension débloquée par le joueur}
		@tailleSelectionnee = nil
		@numeroSelectionne = nil
		@lignes = [] # lignes du tableau de sélection des grilles par numéro
	
		@titre = Gtk::Label.new("#{Main.getMode}").set_name("lblTitre")
		btnRetour = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		btnPrincipal = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/home.png"))
		@btnJouer = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/play.png"))
		
		@tableMid = Gtk::Table.new(1,2,true)
		@tableBottom = Gtk::Table.new(1,3,true).set_col_spacings(10)
		
		scrollZoneTailles = Gtk::ScrolledWindow.new
			.set_policy(Gtk::PolicyType::NEVER, Gtk::PolicyType::ALWAYS)
			.set_size_request(150,150)
		@scrollZoneNumero = Gtk::ScrolledWindow.new
			.set_policy(Gtk::PolicyType::NEVER, Gtk::PolicyType::ALWAYS)
			.set_size_request(50,50)

		# les données sont stockées dans des TreeStore
		@taillesStore = Gtk::TreeStore.new(Integer, String)
	
		# TreeView des Tailles des grilles
		@view = Gtk::TreeView.new(@taillesStore)
		scrollZoneTailles.add(@view)
		@taillesStore.clear
		for i in 6..16 do loadTailleGrille(i) end
		renderer = Gtk::CellRendererText.new
		col1 = Gtk::TreeViewColumn.new("Taille Grille", renderer, :text => 0)
		col2 = Gtk::TreeViewColumn.new("Progression", renderer, :text => 1)
		@view.set_headers_visible(true)
		@view.append_column(col1)
		@view.append_column(col2)
		@view.signal_connect('cursor-changed') { |widget| onMainViewChanged(widget) }
		
		# TreeView des numéros des grilles
		initTreeview()
		@view.signal_connect('cursor-changed') { |widget|
			if widget.selection.selected != nil
				@numeroSelectionne = widget.selection.selected[0]
			end
		}

		# interaction avec les boutons
		@btnJouer.signal_connect('clicked') { onJouerClicked }
		btnRetour.signal_connect('clicked') { GUIChoixMode.ouvrir(@window, @container) }
		btnPrincipal.signal_connect('clicked') { GUIMenuPrincipal.ouvrir(@window, @container) }
       
		# layout management
		@tableMid.attach(scrollZoneTailles, 0,1,0,1)
		@tableMid.attach(@scrollZoneNumero, 1,2,0,1)
		@tableBottom.attach(btnRetour,0,1,0,1)
		@tableBottom.attach(btnPrincipal,1,2,0,1)
		@tableBottom.attach(@btnJouer, 2,3,0,1)
		
		@container.destroy
		@container = Gtk::Box.new(:vertical, 20)
		GUI.ajouterToolbar(window, @container, false)
		@container.pack_start(@titre, :expand=>false, :fill=>true, :padding=>10)
		@container.pack_start(@tableMid, :expand=>true, :fill=>true, :padding=>0)
		@container.pack_start(@tableBottom, :expand=>false, :fill=>true, :padding=>0)
		@window.add(@container)
		@window.show_all
	end
	
	def initTreeview()
		@numerosStores = Gtk::TreeStore.new(Integer, String)
		@view = Gtk::TreeView.new(@numerosStores)
		@scrollZoneNumero.add(@view)
		renderer = Gtk::CellRendererText.new
		col3 = Gtk::TreeViewColumn.new("Numéro", renderer, :text => 0)
		col4 = Gtk::TreeViewColumn.new("Meilleur Score", renderer, :text =>1)
        @view.set_headers_visible(true)
        @view.append_column(col3)
		@view.append_column(col4)
	end
    
    def loadTailleGrille(i)
        listeTailleGrille = @bdd.recupererNbGrilleDebloquee(Main.getId, i, Main.getMode)
        @grilleParTaille.push({"nb_debloque" => listeTailleGrille[0]["nb_debloque"].to_i})
        iter = @taillesStore.append(nil)
        iter.values = [i, @grilleParTaille[i-6]["nb_debloque"].to_s + "/100"]
    end

    def onJouerClicked()
        if @tailleSelectionnee == nil || @numeroSelectionne == nil
            GUIMessage.ouvrir(@window, "Vous devez sélectionner une grille !", Gtk::MessageType::INFO)
        else
            case(Main.getMode)
                when "Hardcore"
                    GUIHardcore.ouvrir(@tailleSelectionnee, @numeroSelectionne, @window, @container)
                when "Entrainement"
                    GUIEntrainement.ouvrir(@tailleSelectionnee, @numeroSelectionne, @window, @container)
                when "Contre-la-Montre"
                    GUIVsMontre.ouvrir(@tailleSelectionnee, @numeroSelectionne, @window, @container)
            end
        end
    end

    def onMainViewChanged(widget)
        @tailleSelectionnee = widget.selection.selected[0].to_i
        loadData(@tailleSelectionnee)
        @numeroSelectionne = nil
    end

	def loadData(taille)
		listeGrilleJouees = @bdd.recupererGrilleParTaille(Main.getId, taille, Main.getMode)
		# suppression ligne par ligne
		@lignes.each { |l| @numerosStores.remove(l) }
		# suppression des lignes de notre variable de stockage
		@lignes.clear

		for i in 1..100 do
			iter = @numerosStores.append(nil)
			iter.values = [i, "-- : -- : --"]
			@lignes.push(iter)
		end

		listeGrilleJouees.each { |j|
			@lignes[j["numero_grille"]-1].values = [j["numero_grille"], Time.at(j["score"]).utc.strftime("%H:%M:%S")]
		}
	end

end