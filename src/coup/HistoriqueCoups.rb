require_relative 'Coup.rb'

# Gestionnaire de coups
class HistoriqueCoups
	attr_reader :indiceCourant

	def HistoriqueCoups.creer(grille)
		new(grille)
	end
	private_class_method :new

	def initialize(grille)
		@indiceCourant = 0
		@coups = Array.new
		@coups.push(Coup.enregistrer(grille))
		
	end

	def addCoup(grille)
		@coups.push(Coup.enregistrer(grille))
		@indiceCourant += 1
	end

	def restoreCoup(indice)
		@indiceCourant = indice
		return Marshal.load(@coups[@indiceCourant].grille)
	end

	def restoreCoupPrec()
		if @indiceCourant > 0 then
			@indiceCourant -= 1
			return Marshal.load(@coups[@indiceCourant].grille)
		else
			return Marshal.load(@coups.first.grille)
		end
	end

	def restoreCoupSuiv()
		if @indiceCourant+1 != @coups.size then
			@indiceCourant += 1
			return Marshal.load(@coups[@indiceCourant].grille)
		else
			return Marshal.load(@coups.last.grille)
		end
	end

	def nbCoups()
		return @coups.size
	end

end