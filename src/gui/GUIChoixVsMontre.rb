class GUIChoixVsMontre < GUIChoixPartie
	@@pwd = File.dirname(__FILE__)

	def GUIChoixVsMontre.ouvrir(window, container)
        new(window,container)
    end
    private_class_method :new

    def initialize(window, container)
    	super(window,container)
    end

    def initTreeview()
        @numerosStores = Gtk::TreeStore.new(Integer, String, String)
        @view = Gtk::TreeView.new(@numerosStores)
        @scrollZoneNumero.add(@view)
        renderer = Gtk::CellRendererText.new
        col3 = Gtk::TreeViewColumn.new("Numéro", renderer, :text => 0)
        col4 = Gtk::TreeViewColumn.new("Meilleur Score", renderer, :text =>1)
        col5 = Gtk::TreeViewColumn.new("Temps Imparti", renderer, :text =>2)
        @view.set_headers_visible(true)
        @view.append_column(col3)
        @view.append_column(col4)
        @view.append_column(col5)
    end
    

    def loadData(taille)
        listeGrilleJouees = @bdd.recupererGrilleParTaille(Main.getId, taille, Main.getMode)
        # suppression ligne par ligne
        @lignes.each { |l| @numerosStores.remove(l) }
        # suppression des lignes de notre variable de stockage
        @lignes.clear
    
        for i in 1..100 do
            iter = @numerosStores.append(nil)
            iter.values = [i, "-- : -- : --", "#{Time.at(@bdd.recupererTempsMax(taille)).utc.strftime("%H:%M:%S")}"]
            @lignes.push(iter)
        end
    
        listeGrilleJouees.each { |j|
			@lignes[j["numero_grille"]-1].values = [
                j["numero_grille"],
                Time.at(j["score"]).utc.strftime("%H:%M:%S")]
		}
    end
    
end