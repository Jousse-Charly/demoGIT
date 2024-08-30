class Case
	attr_reader :type, :l, :c

	def Case.creer(type, ligne, colonne)
		new(type, ligne, colonne)
	end
	private_class_method :new

	def initialize(type, ligne, colonne)
		@type = type
		@l = ligne
		@c = colonne
	end

	def engazonner()
		@type = '_' if !self.estArbre?
	end

	def placerTente()
		@type = 'T' if !self.estArbre?
	end

	def supprimer()
		@type = ' ' if !self.estArbre?
	end

	def estArbre?()
		return self.type == 'A'
	end

	def estTente?()
		return self.type == 'T'
	end

	def estGazon?()
		return self.type == '_'
	end

	def estVide?()
		return self.type == ' '
	end
	
end