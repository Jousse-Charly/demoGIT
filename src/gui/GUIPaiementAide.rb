module GUIPaiementAide
	@@pwd = File.dirname(__FILE__)
	
	def GUIPaiementAide.ouvrir(parent, parentWindow, systemeAide, systemeScore, grille)
		@bddManager = GestionnaireBaseDeDonnees.getInstance
		@creditJoueur = @bddManager.recupererCagnotteJoueur(Main.getId)
		
		aide = systemeAide.demander(grille)

		if aide.impossible? || aide.dejaAuMax?
				parent.afficherAide(aide)
		else
			if Main.getMode == "Entrainement"
				systemeScore.updateNbAideUtilisee
				parent.afficherAide(aide)
			else
				paiementOK = false
				@popUp = GUIPopUp.ouvrir(parentWindow).set_title("Paiement Aide")
				container = Gtk::Box.new(:vertical, 10)
				tableBottom = Gtk::Table.new(1,2,true).set_col_spacings(10)

				# widgets
				btnTemps = Gtk::RadioButton.new(label: "#{aide.malusCourant}\"")
					.set_margin_left(20)
				btnEtoile = Gtk::RadioButton.new(member: btnTemps, label: "#{aide.prixCourant}")
					.set_name("radioCredit")
				btnEtoile.sensitive = false if @creditJoueur < aide.prixCourant
				btnAnnuler = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/cancel.png"))
				btnAccepter = Gtk::Button.new.set_image(Gtk::Image.new(file: "#{@@pwd}/../../img/ok.png"))

				# signaux
				btnAnnuler.signal_connect('clicked') {
					@popUp.destroy
				}

				btnAccepter.signal_connect('clicked') {
					if btnTemps.active?
						systemeScore.updateMalus(aide.malusCourant)
					else
						@bddManager.ajouterACagnotte(Main.getId, aide.prixCourant * -1)
						parent.updateCredit(@bddManager.recupererCagnotteJoueur(Main.getId))
					end
					systemeScore.updateNbAideUtilisee
					paiementOK = true
					parent.afficherAide(aide)
					@popUp.destroy
				}

				@popUp.signal_connect('destroy') {
					systemeAide.annuler if !paiementOK
				}		

				# layout managment
				if Main.getMode == "Aventure"
					container.add(Gtk::Label.new("Comment souhaitez-vous payer ?"))
					tableMid = Gtk::Table.new(1,3,true)
					tableMid.attach(btnTemps, 0,1,0,1)
					tableMid.attach(btnEtoile, 2,3,0,1)
					container.pack_start(tableMid, :expand=>true, :fill=>true, :padding=>20)
				else
					container.add(Gtk::Label.new("Souhaitez-vous payer l'aide pour #{aide.malusCourant}\" de malus ?"))
				end
				tableBottom.attach(btnAccepter, 0,1,0,1)
				tableBottom.attach(btnAnnuler, 1,2,0,1)
				container.add(tableBottom)
				@popUp.add(container)
				@popUp.show_all
			end
		end
	end
	
end
