# Lance un popUp contenant un message personnalisé
module GUIMessage
	def GUIMessage.ouvrir(parentWindow, msg, type)
		dialog = Gtk::MessageDialog.new(
			parent: parentWindow,
			flags: Gtk::DialogFlags::DESTROY_WITH_PARENT,
			type: type,
			buttons: Gtk::ButtonsType::CLOSE,
			message: msg)
		dialog.run
		dialog.destroy
	end
end




