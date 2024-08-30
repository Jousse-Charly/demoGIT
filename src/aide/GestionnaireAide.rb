require_relative 'AideTenteDiagonaleAbr.rb'
require_relative 'AideTenteAucunArbre.rb'
require_relative 'AideTenteMalPlacee.rb'
require_relative 'AideGazonMalPlace.rb'
require_relative 'AideTropDeTente.rb'
require_relative 'AidePasAssezDeTente.rb'
require_relative 'AideResteQueGazon.rb'
require_relative 'AideResteQueTente.rb'
require_relative 'AideCaseAEngazonner.rb'
require_relative 'AideArbreUniqueSoluce.rb'
require_relative 'AideVideAutourTente.rb'
require_relative 'AideArbreDejaUtilise.rb'
require_relative 'AideImpossible.rb'

# Classe permettant la gestion des différentes aides du jeu
class GestionnaireAide
	def GestionnaireAide.creer(grille)
		new(grille)
	end
	private_class_method :new

	def initialize(grille)
		@lastGrille = Marshal.dump(grille)
		@lastAide = nil
		@listeAide = Array.new
        @listeAide.push(AideTenteDiagonaleAbr.creer)
        @listeAide.push(AideTenteAucunArbre.creer)
        @listeAide.push(AideTropDeTente.creer)
        @listeAide.push(AidePasAssezDeTente.creer)
		@listeAide.push(AideTenteMalPlacee.creer)
        @listeAide.push(AideGazonMalPlace.creer)
		@listeAide.push(AideResteQueGazon.creer)
		@listeAide.push(AideResteQueTente.creer)
		@listeAide.push(AideCaseAEngazonner.creer)
		@listeAide.push(AideVideAutourTente.creer)
		@listeAide.push(AideArbreUniqueSoluce.creer)
		@listeAide.push(AideArbreDejaUtilise.creer)
		@listeAide.push(AideImpossible.creer)
	end

	# Renvoie la première aide capable de répondre sinon augmente la précision de la dernière aide appelée
	def demander(grille)
		@tmpAide = Marshal.dump(@lastAide)
		if @lastAide != nil && grille.estIdentique?(Marshal.load(@lastGrille)) then
			@lastAide.affiner
			@lastAide.aider(grille)
		else
			@lastAide.reset if @lastAide != nil
			@listeAide.each { |aide|
				if aide.aider(grille) then
					@lastAide = aide
					@lastGrille = Marshal.dump(grille)
					break
				end
			}
		end
		return @lastAide
	end

	# Restaure le système d'aide avant l'appel de la dernière aide
	def annuler()
		@lastAide = Marshal.load(@tmpAide)
	end
	
end
