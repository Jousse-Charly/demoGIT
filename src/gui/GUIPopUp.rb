# Créé une fenêtre popUp centrée par rapport au parent appelant.
# Le focus est également réglé de façon à bloquer l'accès à la fenêtre parente tant que la popUp n'est pas fermée.
module GUIPopUp
	def GUIPopUp.ouvrir(parent)
		window = Gtk::Window.new
		window.set_decorated(false)
		window.set_resizable(false)
		window.border_width = 10
		window.set_modal(true)
		window.set_transient_for(parent)
		window.set_window_position(Gtk::WindowPosition::CENTER_ON_PARENT)
		return window.set_name("popup")
	end
end




