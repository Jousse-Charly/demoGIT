module GUIMenuPrincipal
	@@pwd = File.dirname(__FILE__)

	def GUIMenuPrincipal.ouvrir(window, container)
		# définition des widgets
		btnJouer = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/jouer.png"))
			.set_tooltip_markup('<span foreground="black">Jouer</span>')
			.set_vexpand(true)
		btnScores = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/scores.png"))
			.set_tooltip_markup('<span foreground="black">Scores</span>')
			.set_vexpand(true)
		btnSucces = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/succes.png"))
			.set_tooltip_markup('<span foreground="black">Succès</span>')
			.set_vexpand(true)
		btnClassements = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/classements.png"))
			.set_tooltip_markup('<span foreground="black">Classements</span>')
			.set_vexpand(true)
		btnRetour = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/prev.png"))
		
		# intéraction avec les boutons
		btnRetour.signal_connect('clicked') {GUIChoixProfil.ouvrir(window,container)}
		btnScores.signal_connect('clicked') {GUIScore.ouvrir(window,container)}
		btnSucces.signal_connect('clicked') {GUISucces.ouvrir(window,container)}
		btnClassements.signal_connect('clicked') {GUIClassement.ouvrir(window,container)}
		btnJouer.signal_connect('clicked') {GUIChoixMode.ouvrir(window,container)}

		# placement des widgets dans le container
		container.destroy
		container = Gtk::Box.new(:vertical, 20)
		GUI.ajouterToolbar(window, container, false)

		container.pack_start(Gtk::Label.new("Veuillez sélectionner un menu").set_name("lblTitre"), :expand=>false, :fill=>true, :padding=>10)
		tableBtn = Gtk::Table.new(2,2,true).set_row_spacings(20).set_col_spacings(20)
		tableBtn.attach(btnJouer, 0,1,0,1)
		tableBtn.attach(btnSucces, 1,2,0,1)
		tableBtn.attach(btnScores, 0,1,1,2)
		tableBtn.attach(btnClassements, 1,2,1,2)
		container.add(tableBtn)
		container.add(btnRetour)
		window.add(container)
		window.show_all
	end
end
