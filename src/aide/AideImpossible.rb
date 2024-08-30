require_relative 'Aide.rb'

class AideImpossible < Aide
	def AideImpossible.creer()
		new()
	end

	def initialize()
		@titre = "Aucune aide trouvée !"
		@prix = 0
		@malus = 0
		@precision = 1
		@precisionMax = 1
	end

	def aider(grille)
		return true
	end

end