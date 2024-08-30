require 'gtk3'
require 'sdl2'

require_relative 'GUIPopUp.rb'
require_relative 'GUIOuiNon.rb'
require_relative 'GUIMessage.rb'

require_relative 'GUIChoixProfil.rb'
require_relative 'GUIMenuPrincipal.rb'
require_relative 'GUIChoixMode.rb'
require_relative 'GUIChoixPartie.rb'
require_relative 'GUIChoixAventure.rb'
require_relative 'GUIChoixVsMontre.rb'
require_relative 'GUIPartie.rb'
require_relative 'GUIAventure.rb'
require_relative 'GUIHardcore.rb'
require_relative 'GUIVsMontre.rb'
require_relative 'GUIEntrainement.rb'
require_relative 'GUISucces.rb'
require_relative 'GUIScore.rb'
require_relative 'GUIClassement.rb'
require_relative 'GUINouveau.rb'
require_relative 'GUIPaiementAide.rb'

require_relative '../grille/GrilleJeu.rb'
require_relative '../aide/GestionnaireAide.rb'
require_relative '../coup/Checkpoints.rb'
require_relative '../score/CalculateurScore.rb'
require_relative '../utils/Chronometre.rb'
require_relative '../utils/Minuteur.rb'
require_relative '../utils/Sauvegarde.rb'
require_relative '../bdd/GestionnaireBaseDeDonnees.rb'
require_relative '../succes/GestionnaireSucces.rb'

# Créer et configure l'unique fenêtre utilisée tout au long du jeu.
# Seul le container sera modifié pour mettre à jour le contenu lors d'un changement de menu de jeu.
module GUI
	@@pwd = File.dirname(__FILE__)

	def GUI.lancer()
		# Css
		provider = Gtk::CssProvider.new
		provider.load(path: "#{@@pwd}/style.css")
		Gtk::StyleContext::add_provider_for_screen(Gdk::Screen.default,provider,Gtk::StyleProvider::PRIORITY_APPLICATION)

		# Window
		window = Gtk::Window.new.set_name("paysage")
		window.border_width = 0
		window.set_resizable(true)
		window.set_title("Tents and Trees Puzzle")
		window.set_icon("#{@@pwd}/../../img/tent.png")
		window.set_window_position(Gtk::WindowPosition::CENTER)
		window.signal_connect('destroy') {Gtk.main_quit}

		# Soundtrack
		SDL2::init(SDL2::INIT_AUDIO)
		SDL2::Mixer.open(22050, SDL2::Mixer::DEFAULT_FORMAT, 2, 512)
		SDL2::Mixer::MusicChannel.volume = 128
		SDL2::Mixer::MusicChannel.fade_in(SDL2::Mixer::Music.load("#{@@pwd}/../../track/ww.ogg"), -1, 1000)

		GUIChoixProfil.ouvrir(window, Gtk::Box.new(:vertical, 0))
		Gtk.main
	end

	def GUI.ajouterToolbar(window, container, askToQuit)
		# Items
		paysage = Gtk::MenuItem.new(label: "Paysage")
		foret = Gtk::MenuItem.new(label: "Forêt")
		nuit = Gtk::MenuItem.new(label: "Nuit")

		activer = Gtk::MenuItem.new(label: "Activer")
		desactiver = Gtk::MenuItem.new(label: "Désactiver")
		rejouer = Gtk::MenuItem.new(label: "Rejouer")

		fullscreen = Gtk::MenuItem.new(label: "Plein Écran")
		windowed = Gtk::MenuItem.new(label: "Fenêtré")
		quitter = Gtk::MenuItem.new(label: "Quitter")
	
		# Signaux
		paysage.signal_connect("activate") {
			window.set_name("paysage")
			SDL2::Mixer::MusicChannel.halt
			SDL2::Mixer::MusicChannel.fade_in(SDL2::Mixer::Music.load("#{@@pwd}/../../track/ww.ogg"), -1, 1000)
		}
		foret.signal_connect("activate") {
			window.set_name("foret")
			SDL2::Mixer::MusicChannel.halt
			SDL2::Mixer::MusicChannel.fade_in(SDL2::Mixer::Music.load("#{@@pwd}/../../track/botw.ogg"), -1, 1000)
		}
		nuit.signal_connect("activate") {
			window.set_name("nuit")
			SDL2::Mixer::MusicChannel.halt
			SDL2::Mixer::MusicChannel.fade_in(SDL2::Mixer::Music.load("#{@@pwd}/../../track/oot.ogg"), -1, 1000)
		}

		activer.signal_connect("activate") {SDL2::Mixer::MusicChannel.volume = 128}
		desactiver.signal_connect("activate") {SDL2::Mixer::MusicChannel.volume = 0}
		rejouer.signal_connect("activate") {SDL2::Mixer::MusicChannel.rewind}

		fullscreen.signal_connect("activate") {window.fullscreen}
		windowed.signal_connect("activate") {window.unfullscreen}
		quitter.signal_connect("activate") {
			if askToQuit
				GUIOuiNon.ouvrir(window, "Voulez-vous vraiment quitter le jeu ?") do
					Gtk.main_quit
				end
			else
				Gtk.main_quit
			end
		}

		# Menus
		themeMenu = Gtk::Menu.new
			.add(paysage)
			.add(foret)
			.add(nuit)
		sonMenu = Gtk::Menu.new
			.add(activer)
			.add(desactiver)
			.add(rejouer)
		ecranMenu = Gtk::Menu.new
			.add(fullscreen)
			.add(windowed)
			.add(quitter)

		theme = Gtk::MenuItem.new(label: "Thème")
		theme.submenu = themeMenu
		son = Gtk::MenuItem.new(label: "Son")
		son.submenu = sonMenu
		ecran = Gtk::MenuItem.new(label: "Écran")
		ecran.submenu = ecranMenu
		
		menuBar = Gtk::MenuBar.new
			.append(theme)
			.append(son)
			.append(ecran)

        container.pack_start menuBar, expand: false, fill: false, padding: 0
	end

end
