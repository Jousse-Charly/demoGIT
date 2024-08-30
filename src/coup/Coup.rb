# un coup se réduit à la sérialisation d'une grille
class Coup
	attr_reader :grille

	def Coup.enregistrer(grille)
		new(grille)
	end
	private_class_method :new

	def initialize(grille)
		@grille = Marshal.dump(grille)
	end

end