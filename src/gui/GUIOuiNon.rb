# Créé une fenêtre de type Oui/Non avec un message personnalisé.
# Un bloc d'instructions à éxécuter peut être indiqué dans le cas d'un clic sur Oui.
class GUIOuiNon
	@@pwd = File.dirname(__FILE__)

	def GUIOuiNon.ouvrir(parentWindow, msg)
		container = Gtk::Box.new(:vertical, 10)
		popUp = GUIPopUp.ouvrir(parentWindow)
		tableBottom = Gtk::Table.new(1,2,true).set_col_spacings(10)
		popUp.set_title("Attention !")
					
		btnAnnuler = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/cancel.png"))
		btnAccepter = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/ok.png"))
		
		btnAnnuler.signal_connect('clicked') {
			popUp.destroy
		}

		btnAccepter.signal_connect('clicked') {
			popUp.destroy
			yield
		}

		container.add(Gtk::Label.new(msg).set_vexpand(true))	
		tableBottom.attach(btnAccepter, 0,1,0,1)
		tableBottom.attach(btnAnnuler, 1,2,0,1)
		container.add(tableBottom)
		popUp.add(container)
		popUp.show_all
	end
end
		

		
		