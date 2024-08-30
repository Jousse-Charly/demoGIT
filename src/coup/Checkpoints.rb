require_relative 'HistoriqueCoups.rb'

# Contient les titres et numéros des coups qui servent de checkpoint
class Checkpoints

	def initialize()
		@coupsIndices = Array.new
		@checkpointsTitres = Array.new
	end

	def add(titre, indiceCoup)
		@coupsIndices.push(indiceCoup)
		@checkpointsTitres.push(titre)
	end

	def titre(indice)
		return @checkpointsTitres[indice]
	end

	def indiceCoup(indice)
		return @coupsIndices[indice]
	end

	def eachTitres()
		i = 0
		while i < @checkpointsTitres.length
			yield @checkpointsTitres[i]
			i += 1
		end
	end

end