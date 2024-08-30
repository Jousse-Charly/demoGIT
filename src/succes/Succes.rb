class Succes
    attr_reader :idSucces, :numero_succes, :intitule, :recompense, :idJoueur, :modeJeu

    def initialize(idSucces, numero_succes, intitule, recompense, idJoueur, modeJeu)
        @idSucces = idSucces
        @numero_succes = numero_succes
        @intitule = intitule
        @recompense = recompense
        @joueur = idJoueur
        @modeJeu = modeJeu
    end
end
  