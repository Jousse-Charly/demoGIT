module GUINouveau
	@@pwd = File.dirname(__FILE__)
	
	def GUINouveau.ouvrir(parent, parentWindow)
		container = Gtk::Box.new(:vertical, 10)
		tableBottom = Gtk::Table.new(1,2,true).set_col_spacings(10)
		popUp = GUIPopUp.ouvrir(parentWindow)
		popUp.set_title("Nouveau Profil")
		
		info = Gtk::Label.new("Choisissez un pseudonyme")
		pseudo = Gtk::Entry.new.set_vexpand(true)
		btnValider = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/ok.png"))
		btnRetour = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/cancel.png"))

		btnValider.signal_connect('clicked') {
			if pseudo.text != ""
				begin
					id = GestionnaireBaseDeDonnees.getInstance.ajouterJoueur(pseudo.text)
					GestionnaireSucces.new(id).profileCreer
					parent.refresh
					popUp.destroy
				rescue Exception => e
					popUp.destroy
					GUIMessage.ouvrir(parentWindow, "Pseudo invalide ou déjà utilisé !", Gtk::MessageType::WARNING)
				end
			end
		}
		btnRetour.signal_connect('clicked') {
			popUp.destroy
		}

		container.add(info)
		container.add(pseudo)
		tableBottom.attach(btnValider, 0,1,0,1)
		tableBottom.attach(btnRetour, 1,2,0,1)
		container.add(tableBottom)
		popUp.add(container)
		popUp.show_all
	end
end