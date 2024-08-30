require_relative 'Aide.rb'

class AideTenteMalPlacee < Aide
	def AideTenteMalPlacee.creer()
		new()
	end

	def initialize()
		@prix = 8
		@malus = 3
		@precision = 1
		@precisionMax = 3
	end

	def aider(grille)
		pos = ""
		grille.taille.times do |l|
            grille.taille.times do |c|
				if grille.estTente?(l,c) && !grille.soluce.estTente?(l,c) then
                    pos,n = "ligne",l if grille.nb(' ','l',l) > 0
                    pos,n = "colonne",c if grille.nb(' ','c',c) > 0
                    if pos != "" then
                        @titre = "Une tente est mal placée !" if @precision == 1
					    @titre = "Une tente est mal placée sur la #{pos} #{n+1} !" if @precision == 2
					    @titre = "Une tente est mal placée sur la case (#{l+1},#{c+1}) !" if @precision == 3
						super
						return true
                    end
                end
			end
		end
		return false
	end

end
