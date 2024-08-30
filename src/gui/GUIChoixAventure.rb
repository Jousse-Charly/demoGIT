class GUIChoixAventure < GUIChoixPartie
	@@pwd = File.dirname(__FILE__)
	@tempDebloque = 1 # la taille 6x6 est toujours debloquée

	def GUIChoixAventure.ouvrir(window, container)
        new(window, container)
    end

    def initialize(window, container)
    	super(window, container)
    end

	def loadTailleGrille(i)
        listeTailleGrille = @bdd.recupererNbGrilleDebloquee(Main.getId, i, "Aventure")

		# débloquage automatique par le nombre de grilles finies
		if listeTailleGrille[0]["nb_debloque"] >= 25 && i < 16
			@bdd.deverrouillerDimensionGrille(Main.getId, i+1)
			tempDebloque = 1
		else
			tempDebloque = listeTailleGrille[0]["estDeverrouille"]
		end

		@grilleParTaille.push({"nb_debloque" => listeTailleGrille[0]["nb_debloque"].to_i, "estDeverrouille" => tempDebloque, "cout" => listeTailleGrille[0]["cout"].to_i})
		iter = @taillesStore.append(nil)
		iter.values = [i, @grilleParTaille[i-6]["nb_debloque"].to_s + "/100"]
    end

    def onJouerClicked()
        if @tailleSelectionnee != nil && @grilleParTaille[@tailleSelectionnee-6]["estDeverrouille"] == 0
			taille = @tailleSelectionnee
			cout = @grilleParTaille[@tailleSelectionnee-6]["cout"]
			grillesEnPause = @bdd.sauvegardesJoueur(Main.getId)
			GUIOuiNon.ouvrir(@window, "Voulez-vous débloquer le niveau " + taille.to_s + " pour " + cout.to_s + " crédits ?") do
				debloquerTaille(taille,cout)
			end
		elsif @tailleSelectionnee == nil || @numeroSelectionne == nil
			GUIMessage.ouvrir(@window, "Vous devez sélectionner une grille !", Gtk::MessageType::INFO)
		elsif @grilleParTaille[@tailleSelectionnee-6]["estDeverrouille"] == 1
			GUIAventure.ouvrir(@tailleSelectionnee, @numeroSelectionne, @window, @container, @numerosEnPause.index(@numeroSelectionne) != nil)
		else
			GUIMessage.ouvrir(@window, "La grille sélectionnée n'est pas disponible !", Gtk::MessageType::INFO)
		end
    end

    def onMainViewChanged(widget)
        @tailleSelectionnee = widget.selection.selected[0].to_i

		if @tailleSelectionnee != nil && @grilleParTaille[@tailleSelectionnee-6]["estDeverrouille"] == 0
			@btnJouer.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/unlock.png"))
		else
			@btnJouer.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/play.png"))
		end

		loadData(@tailleSelectionnee)
		@numeroSelectionne = nil
    end

	def loadData(taille)
		listeGrilleJouees = @bdd.recupererGrilleParTaille(Main.getId, taille, "Aventure")
		listeGrillesEnPause = @bdd.sauvegardesJoueur(Main.getId)
		# suppression ligne par ligne
		@lignes.each { |l| @numerosStores.remove(l) }
		# suppression des lignes de notre variable de stockage
		@lignes.clear

		for i in 1..100 do
			iter = @numerosStores.append(nil)
			iter.values = [i, @grilleParTaille[taille-6]["estDeverrouille"] == 1 ? "-- : -- : --" : "Grille à déverrouiller"]
			
			@lignes.push(iter)
		end

		listeGrilleJouees.each { |j|
			@lignes[j["numero_grille"]-1].values = [j["numero_grille"], Time.at(j["score"]).utc.strftime("%H:%M:%S")]
		}

		@numerosEnPause = Array.new
		listeGrillesEnPause.each { |pause|
			if pause["taille"] == taille
				@lignes[pause["numero"]-1].values = [pause["numero"], "En pause"]
				@numerosEnPause.push(pause["numero"])
			end
		}
	end

	def debloquerTaille(taille, cout)
		if @bdd.recupererCagnotteJoueur(Main.getId) >= cout
			@bdd.deverrouillerDimensionGrille(Main.getId, taille)
			@bdd.ajouterACagnotte(Main.getId, cout * -1)
			@grilleParTaille[taille-6]["estDeverrouille"] = 1
			loadData(taille);
			@btnJouer.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/play.png"))
		else
			GUIMessage.ouvrir(@window, "Crédit insuffisant pour débloquer cette taille !", Gtk::MessageType::INFO)
		end
	end
	
end