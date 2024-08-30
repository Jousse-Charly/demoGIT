module GUIChoixMode
	@@pwd = File.dirname(__FILE__)

	def GUIChoixMode.ouvrir(window,container)
		# création des widgets
		btnAventure = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/aventure.png"))
			.set_tooltip_markup('<span foreground="black">Aventure</span>')
			.set_vexpand(true)
		btnVsMontre = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/vs_montre.png"))
			.set_tooltip_markup('<span foreground="black">Contre-la-Montre</span>')
			.set_vexpand(true)
		btnHardcore = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/hardcore.png"))
			.set_tooltip_markup('<span foreground="black">Hardcore</span>')
			.set_vexpand(true)
		btnEntrain = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/training.png"))
			.set_tooltip_markup('<span foreground="black">Entraînement</span>')
			.set_vexpand(true)
		btnRetour = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		btnCompte = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/account.png"))

		# intéraction avec les boutons
		btnAventure.signal_connect('clicked') {
			Main.setMode("Aventure")
			GUIChoixAventure.ouvrir(window,container)
		}
		btnVsMontre.signal_connect('clicked') {
			Main.setMode("Contre-la-Montre")
			GUIChoixVsMontre.ouvrir(window,container)
		}
		btnHardcore.signal_connect('clicked') {
			Main.setMode("Hardcore")
			GUIChoixPartie.ouvrir(window,container)
		}
		btnEntrain.signal_connect('clicked') {
			Main.setMode("Entrainement")
			GUIChoixPartie.ouvrir(window,container)
		}
		btnRetour.signal_connect('clicked') {
			GUIMenuPrincipal.ouvrir(window,container)
		}
		btnCompte.signal_connect('clicked') {
			GUIChoixProfil.ouvrir(window,container)
		}

		# placement des widgets dans le container
		container.destroy
		container = Gtk::Box.new(:vertical, 20)
		tableBtn = Gtk::Table.new(2,2,true).set_row_spacings(20).set_col_spacings(20)
			.attach(btnAventure, 0,1,0,1)
			.attach(btnVsMontre, 1,2,0,1)
			.attach(btnHardcore, 0,1,1,2)
			.attach(btnEntrain, 1,2,1,2)
		tableBottom = Gtk::Table.new(1,2,true).set_col_spacings(10)
			.attach(btnRetour, 0,1,0,1)
			.attach(btnCompte, 1,2,0,1)

		GUI.ajouterToolbar(window, container, false)
		container.pack_start(Gtk::Label.new("Veuillez sélectionner un mode de jeu").set_name("lblTitre"), :expand=>false, :fill=>true, :padding=>10)
		container.add(tableBtn)
		container.add(tableBottom)
		window.add(container)
		window.show_all
	end
end