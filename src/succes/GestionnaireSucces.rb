require_relative 'Succes.rb'
require_relative '../score/CalculateurScore.rb'

class GestionnaireSucces
    # @listeSuccesDisponibles Liste des succès non debloqués.
    # @listeDefisDisponibles Liste des succes non debloqués.
    # @listeTentePlacee Liste des tentes placée.
    # @listeCombo Liste des combo realises
    # @tenteConsecutives

    def new(id_joueur)
        new(id_joueur)
    end

    # Initialisation d'un gestionnaire de succès. (Récuperation des succès non debloqués dans la base de données)
    def initialize(id_joueur)
        @id_joueur = id_joueur
        @listeSuccesDisponibles = Array.new
        @listeTentePlacee = Array.new
        @listeDefisDisponibles = Array.new
        @listeCombo = Array.new
        @tenteConsecutives = 0
        @gestionnaireBaseDeDonnees = GestionnaireBaseDeDonnees.new

        succes = @gestionnaireBaseDeDonnees.recupererSucces(@id_joueur)

        succes.each { |s|
            if s["estDebloque_succes"] == 0 && s["estReiterable_succes"] == 0
                @listeSuccesDisponibles.push(Succes.new(s["id_succes"], s["numero_succes"], s["intitule_succes"], s["recompense_succes"], @id_joueur, "Aventure"))
            elsif s["estReiterable_succes"] == 1
                @listeDefisDisponibles.push(Succes.new(s["id_succes"], s["numero_succes"], s["intitule_succes"], s["recompense_succes"], @id_joueur, "Aventure"))
            end
        }
    end
    # Récuperation d'un succès par sont numero_succes.
    def getSuccesByNumero(numero_succes)
        temp = nil
        @listeSuccesDisponibles.each { |s|
            temp = s if s.numero_succes == numero_succes
        }
        @listeSuccesDisponibles.delete(temp)
        return temp
    end
    # Récuperation d'un défit (succès réiterable) par sont numero_succes.
    def getDefisByNumero(numero_succes)
        @listeDefisDisponibles.each { |s|
            return s if s.numero_succes == numero_succes
        }
        return nil
    end
    # Méthode à appeler quand un profil est créer pour vérifier s'il peut etre débloqué.
    def profileCreer()
        temp = getSuccesByNumero(1)
        if temp != nil && @id_joueur == 3
            @gestionnaireBaseDeDonnees.obtentionSucces(@id_joueur, temp.numero_succes)
        end
    end
    # Méthode à appeler quand on effectue une sauvegarde pour vérifier s'il peut etre débloqué.
    def sauvegarde()
        temp = getSuccesByNumero(2)
        if temp != nil
            @gestionnaireBaseDeDonnees.obtentionSucces(@id_joueur, temp.numero_succes)
        end
    end

    # Méthode appelée à la fin de chaque grille permettant de débloquer les succès concernés
    def finGrille(taille)
        temp = getDefisByNumero(16)
        if temp != nil && CalculateurScore.nbAideUtilisee == 0
            @gestionnaireBaseDeDonnees.obtentionSucces(@id_joueur, temp.numero_succes)
        end

        temp = getSuccesByNumero(9)
        if temp != nil && CalculateurScore.nbAideUtilisee == 1
            @gestionnaireBaseDeDonnees.obtentionSucces(@id_joueur, temp.numero_succes)
        end
    end
    # Méthode à appeler quand une tente est placée, pour verifier si c'est un combo.
    def tenteSuccessive(l, c)
        if @listeTentePlacee.index(l.to_s + ":" + c.to_s) == nil
            @tenteConsecutives += 1
            @listeTentePlacee.push(l.to_s + ":" + c.to_s)
        end
    end
    # Méthode permettant d'arrêter de compter les tentes successives.
    def resetTenteSuccessive()
        temp = getDefisByNumero(15)
        @listeCombo.push(@tenteConsecutives) if temp != nil
        @tenteConsecutives = 0
    end
    # Méthode à appeler à la fin de la partie pour comptabiliser les combos.
    def finTenteSuccessive()
        resetTenteSuccessive
        @listeCombo.each { |c|
            @gestionnaireBaseDeDonnees.obtentionSuccesTenteCons(@id_joueur, c)
        }
    end

    def lancementGrille()
        
    end

    def utilisationCredit()

    end

    def tousLesSucces()

    end
    
end