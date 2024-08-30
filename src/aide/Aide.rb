# Classe abstraite d'aide
class Aide
	attr_reader :titre, :precision, :malusCourant, :malus, :prix, :prixCourant
	private_class_method :new

    # Permet d'affiner le niveau de précision des aides
	def affiner()
		@precision += 1 if @precision <= @precisionMax
	end

    # Permet de changer la valeur du malus en fonction de la précision 
	def updateMalus()
		if @precision <= @precisionMax
			@malusCourant = @precision != 1 ? 1 : @malus
			@prixCourant = @prix if @precision == 1
			@prixCourant = 2 if @precision == 2
			@prixCourant = 1 if @precision == 3
        end
	end

    # Appel de updateMalus après avoir aidé le joueur sur une grille donnée en paramètre
	def aider(grille)
		updateMalus
	end

    # Reset le niveau de précision au niveau 1
	def reset()
		@precision = 1
	end

    # Renvoie vrai si une aide est impossible à trouver
	def impossible?()
		return @titre == "Aucune aide trouvée !" ? true : false
	end

    # Renvoie vrai si la précision est déjà au maximum
	def dejaAuMax?()
		return @precision > @precisionMax ? true : false
	end

	def to_s()
		return "titre : #{@titre}\nmalus : #{@malus}, malusCourant : #{@malusCourant}\nprix : #{@prix}, prixCourant : #{prixCourant}\nprecisionMax : #{@precisionMax}, precision : #{@precision}"
	end
end