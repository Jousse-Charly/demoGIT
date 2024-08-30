require_relative 'FournisseurBaseDeDonnees.rb'

$id_succes_n_credit = 14
$id_succes_tentes_conse = 15
$id_succes_finir_grille_sans_aide = 16
$id_debloquer_niveau = 17

# Classe permettant de gérer toutes les intéractions avec la base de données (Gestionnaire de SQL)
class GestionnaireBaseDeDonnees
    # Initialisation d'un Gestionnaire de base de données
    # Il s'assure que toutes les tables sont bien présentes dans la base de données, dans le cas contraire il les crée
    def initialize()
        FournisseurBaseDeDonnees.executerSQL("CREATE TABLE IF NOT EXISTS joueur(
            id_joueur INTEGER PRIMARY KEY,
            pseudo_joueur VARCHAR(50) NOT NULL,
            cagnotte_joueur INT NOT NULL,
            niveau_joueur VARCHAR(50) NOT NULL DEFAULT '6;1'
        )")

        FournisseurBaseDeDonnees.executerSQL("CREATE TABLE IF NOT EXISTS succes(
            id_succes INTEGER PRIMARY KEY,
            numero_succes INTEGER NOT NULL,
            intitule_succes VARCHAR(100) NOT NULL,
            recompense_succes INT NOT NULL,
            estDebloque_succes BOOLEAN NOT NULL DEFAULT 0,
						estReiterable_sucess BOOLEAN NOT NULL,
            id_joueur INT NOT NULL,
            FOREIGN KEY(id_joueur) REFERENCES joueur(id_joueur) ON DELETE CASCADE
        )")

        FournisseurBaseDeDonnees.executerSQL("CREATE TABLE IF NOT EXISTS grille(
            id_grille INTEGER PRIMARY KEY,
            contenu_grille VARCHAR(500),
            taille_grille INT NOT NULL,
            numero_grille INT NOT NULL
        )")
        FournisseurBaseDeDonnees.executerSQL("CREATE TABLE IF NOT EXISTS score(
            id_score INTEGER PRIMARY KEY,
            id_grille INT,
            id_joueur INT,
            modeJeu_score VARCHAR(10),
            tempsBrut_score INT,
            malus_score INT,
            FOREIGN KEY (id_joueur) REFERENCES joueur(id_joueur) ON DELETE CASCADE,
            FOREIGN KEY (id_grille) REFERENCES grille(id_grille) ON DELETE CASCADE
        )")
        FournisseurBaseDeDonnees.executerSQL("CREATE TABLE IF NOT EXISTS sauvegarde_partie(
            filename STRING PRIMARY KEY,
            id_joueur INT,
            taille INT,
            numero INT,
            FOREIGN KEY (id_joueur) REFERENCES joueur(id_joueur) ON DELETE CASCADE
        )")
        FournisseurBaseDeDonnees.executerSQL("CREATE TABLE IF NOT EXISTS dimension_grille(
            id_dimension_grille INTEGER PRIMARY KEY,
            id_joueur INT,
            taille INT NOT NULL,
            tempsMax INT NOT NULL,
            estDeverrouille BOOLEAN NOT NULL,
            cout INT NOT NULL,
            FOREIGN KEY (id_joueur) REFERENCES joueur(id_joueur) ON DELETE CASCADE
        )")
    end

    def self.getInstance()
      if @instance == nil
        @instance = GestionnaireBaseDeDonnees.new
      end
      return @instance
    end

    # Méthode permettant de créer un joueur dans la base de données.
    # A la création d'un joueur sa cagnotte est de 0 et son niveau de 1.
    #
    # @param [String] pseudo_joueur Le pseudo du joueur à créer.
    #
    # @return idJoueur Identifiant du joueur qui vient d'être inséré.
    def ajouterJoueur(pseudo_joueur)
        cagnotte = 0
        idJoueur = nil
        pseudoAlreadyExits = 0

        begin
          pseudoAlreadyExits = FournisseurBaseDeDonnees.executerSQL("SELECT * FROM joueur WHERE pseudo_joueur=\"#{pseudo_joueur}\"").length > 0
        rescue SQLite3::Exception => e
        end

        raise if (pseudoAlreadyExits)

        begin
            idJoueur = FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO joueur(pseudo_joueur, cagnotte_joueur) VALUES('#{pseudo_joueur}',#{cagnotte})")
        rescue SQLite3::Exception => e
        end

        # Création de tous les succès possibles et affectation de ceux-ci au joueur.
        begin
            FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO succes(numero_succes, intitule_succes, recompense_succes, estReiterable_sucess, id_joueur) VALUES
                (1, 'Être le 3ème profil de créé',										3,   0, #{idJoueur}),
                (2, 'Sauvegarder une grille en cours de résolution',					3,   0, #{idJoueur}),
                (3, 'Être en tête du classement d’une grille (2 joueurs minimum)',		4,   0, #{idJoueur}),
                (4, 'Lancer une partie dans un mode de jeu pour la 1ère fois', 			3,   0,	#{idJoueur}),
                (5, 'Résoudre une grille d’un mode de jeu pour la 1ère fois',			6,   0,	#{idJoueur}),
                (6, 'Résoudre la moitié des grilles d’un niveau',						20,  0, #{idJoueur}),
                (7, 'Finir toutes les grilles d’un niveau',								40,  0, #{idJoueur}),
                (8, 'Finir toutes les grilles de tous les niveaux',						60,  0, #{idJoueur}),
                (9, 'Finir une grille en utilisant qu’une seule aide',					8,   0, #{idJoueur}),
                (11, 'Première utilisation du crédit',									3,   0, #{idJoueur}),
                (12, 'Flambeur (paiement > 50 )',										20,  0, #{idJoueur}),
                (13, 'Débloquer tous les succès',										100, 0, #{idJoueur}),
        (14, 'Arriver à n crédits (n multiple de 100)',		                50,   1, #{idJoueur}),
                (15, 'Plusieurs tentes correctes placées consécutivement',					-1,   1, #{idJoueur}),
        (16, 'Finir une grille sans aide',						                -1,   1, #{idJoueur}),
        (17, 'Débloquer un niveau sans passer par le crédit',					-1,   1, #{idJoueur})")

        rescue SQLite3::Exception => e
            # Comme il y a un eu un problème lors de l'insertion d'au moins un succès pour le joueur alors on indique une erreur et on supprime le joueur qui a été partiellement créé.
            supprimerJoueur(idJoueur)
        end

        begin
          FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO dimension_grille(id_joueur, taille, tempsMax, estDeverrouille, cout) VALUES
            (#{idJoueur}, 6, 90, 1, 0),
            (#{idJoueur}, 7, 105, 0, 15),
            (#{idJoueur}, 8, 240, 0, 30),
            (#{idJoueur}, 9, 510, 0, 45),
            (#{idJoueur}, 10, 660, 0, 60),
            (#{idJoueur}, 11, 1250, 0, 75),
            (#{idJoueur}, 12, 1600, 0, 90),
            (#{idJoueur}, 13, 2160, 0, 105),
            (#{idJoueur}, 14, 2600, 0, 120),
            (#{idJoueur}, 15, 3200, 0, 135),
            (#{idJoueur}, 16, 3600, 0, 150)")
        rescue SQLite3::Exception => e
          # Comme il y a un eu un probleme lors de l'insertion d'au moins un succes pour le joueur alors on indique une erreur et on supprime le joueur qui a été partielement creé.
          FournisseurBaseDeDonnees.executerSQL("DELETE FROM succes WHERE id_joueur=#{idJoueur};")
          supprimerJoueur(idJoueur)
        end

      return idJoueur
    end

    # Méthode permettant de recuperer les joueurs dans la base de donnees
    #
    def recupererJoueurs()
      results = FournisseurBaseDeDonnees.executerSQL("SELECT id_joueur, pseudo_joueur, cagnotte_joueur, niveau_joueur FROM joueur")
      hash = []
      results.each do |result|
        hash.push({ "id_joueur" => result[0], "pseudo_joueur" => result[1], "cagnotte_joueur" => result[2], "niveau_joueur" => result[3]})
      end
      return hash
    end

    # Méthode permettant de charger le joueur à utiliser
    #
    def chargerJoueurs(pseudo_joueur)
      FournisseurBaseDeDonnees.executerSQL("SELECT id_joueur FROM joueur WHERE pseudo_joueur=#{pseudo_joueur}")
    end

  	# Méthode permettant de supprimer un joueur, par son identifiant.
    #
    # @param [Integer] id_joueur L'identifiant du joueur a supprimer'
    def supprimerJoueur(id_joueur)
        FournisseurBaseDeDonnees.executerSQL("DELETE FROM joueur WHERE id_joueur=#{id_joueur}")
    end

    # Méthode permettant de d'augmenter le niveau d'un joueur.
    #
    # @param [Integer] id_joueur L'identifiant du joueur concerné
    def modifierNiveauJoueur(id_joueur, tailleGrille, numeroGrille)
        temp = tailleGrille.to_s + ":" + numeroGrille.to_s
        FournisseurBaseDeDonnees.executerSQL("UPDATE joueur SET niveau_joueur='#{temp}' WHERE id_joueur=#{id_joueur}")
    end

    # Méthode permettant de récupérer les succès d'un joueur précis
    def recupererSucces(id_joueur)
      results = FournisseurBaseDeDonnees.executerSQL("SELECT * FROM succes WHERE id_joueur=#{id_joueur} ORDER BY estDebloque_succes DESC")
      hash = []
      results.each do |result|
        hash.push({ "id_succes" => result[0], "numero_succes" => result[1], "intitule_succes" => result[2], "recompense_succes" => result[3], "estDebloque_succes" => result[4], "estReiterable_succes" => result[5]})
      end
      return hash
    end

  	# Méthode permettant de débloquer un succès pour un joueur précis.
    #
    # @param [Integer] id_joueur L'identifiant du joueur possesseur du succès
  	# @param [Integer] id_succes L'identifiant du succes à débloquer
    def obtentionSucces(id_joueur, id_succes)
      	# Si on est dans le cas du succès 'Plusieurs tentes correctes placées consécutivement'
        if (id_succes == $id_succes_n_credit)
          # Récuperation de la cagnotte du joueur.
          cagnotteJoueur = FournisseurBaseDeDonnees.executerSQL("SELECT cagnotte_joueur FROM joueur WHERE id_joueur=#{id_joueur}")[0][0]
          # Vérification de l'existance du succès avec le nombre n correct.
          dejaFait = FournisseurBaseDeDonnees.executerSQL("SELECT * FROM succes WHERE id_joueur=#{id_joueur} AND numero_succes=#{id_succes} AND intitule_succes like '%cagnotteJoueur%'").length != 0

          # Si la cagnotte est bien un multiple de 100 et que le succes pour ce n n'a pas déjà été débloqué
          if (cagnotteJoueur != 0 && cagnotteJoueur % 100 == 0 && !dejaFait)
            # Insertion d'un nouveau succès avec le nombre n correct.
            FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO succes(numero_succes, intitule_succes, recompense_succes, estDebloque_succes, estReiterable_sucess, id_joueur)
              VALUES(#{$id_succes_n_credit}, 'Arriver à #{cagnotteJoueur} crédits', 50, 1, 0, #{id_joueur})")
            ajouterACagnotte(id_joueur, 50)
          end

        # Si on est dans le cas du succès 'Finir une grille sans aide'
        elsif (id_succes == $id_succes_finir_grille_sans_aide)

          # Récupération de la taille de la grille à l'aide du niveau du joueur (Rappel : 'taille;numero')
          tailleGrille = FournisseurBaseDeDonnees.executerSQL("SELECT niveau_joueur FROM joueur WHERE id_joueur=#{id_joueur}")[0][0].split(';')[0].to_i
          FournisseurBaseDeDonnees.executerSQL("UPDATE succes SET estDebloque_succes = 1 WHERE id_joueur=#{id_joueur} AND numero_succes=#{id_succes}")
          ajouterACagnotte(id_joueur, tailleGrille)

        elsif (id_succes == $id_debloquer_niveau)

          # Récupération de la taille et du numéro de la grille à l'aide du niveau du joueur (Rappel : 'taille;numero')
          tailleGrille = FournisseurBaseDeDonnees.executerSQL("SELECT niveau_joueur FROM joueur WHERE id_joueur=#{id_joueur}")[0][0].split(';')[0].to_i
          niveauGrille = FournisseurBaseDeDonnees.executerSQL("SELECT niveau_joueur FROM joueur WHERE id_joueur=#{id_joueur}")[0][0].split(';')[1].to_i
          FournisseurBaseDeDonnees.executerSQL("UPDATE succes SET estDebloque_succes = 1 WHERE id_joueur=#{id_joueur} AND numero_succes=#{id_succes}")
          ajouterACagnotte(id_joueur, tailleGrille + niveauGrille)

        else

          # Récuperation de la récompense du succès, pour l'ajouter à la cagnotte du joueur.
          credit = FournisseurBaseDeDonnees.executerSQL("SELECT recompense_succes FROM succes WHERE numero_succes=#{id_succes}")[0][0].to_i
          FournisseurBaseDeDonnees.executerSQL("UPDATE succes SET estDebloque_succes = 1 WHERE id_joueur=#{id_joueur} AND numero_succes=#{id_succes}")
          ajouterACagnotte(id_joueur, credit)

        end
    end

  	# Méthode permettant de débloquer le succès des tentes correctes successives pour un joueur précis.
    #
    # @param [Integer] id_joueur L'identifiant du joueur possesseur du succès
  	# @param [Integer] compt_tente_cons Le nombre de tentes correctes successives
  	def obtentionSuccesTenteCons(id_joueur, compt_tente_cons)
      	if(compt_tente_cons>=3)
        	FournisseurBaseDeDonnees.executerInsertSQL("UPDATE succes SET estDebloque_succes = 1 WHERE id_joueur=#{id_joueur} AND numero_succes=#{$id_succes_tentes_conse}")
      		ajouterACagnotte(id_joueur, compt_tente_cons - 2)
        end
      end

    # Méthode permettant de mettre à jour la cagnotte du joueur.
    #
    # @param [Integer] id_joueur L'identifiant du joueur concerné.
  	# @param [Integer] value Nombre de crédits à ajouter ou enlever.
    def ajouterACagnotte(id_joueur, value)
        FournisseurBaseDeDonnees.executerSQL("UPDATE joueur SET cagnotte_joueur = cagnotte_joueur + #{value} WHERE id_joueur=#{id_joueur}")
      	obtentionSucces(id_joueur, 14)
    end

    # Méthode permettant de récupérer la cagnotte d'un joueur
    #
    # @param [Integer] id_joueur L'identifiant du joueur concerné.
    def recupererCagnotteJoueur(id_joueur)
      FournisseurBaseDeDonnees.executerSQL("SELECT cagnotte_joueur FROM joueur WHERE id_joueur=#{id_joueur}")[0][0]
    end

  	# Méthode permettant d'ajouter un score dans la base de données.
    # A la création d'un score une grille est créée.
    #
    # @param [Integer] id_joueur Identifiant du joueur auquel ajouter le score.
  	# @param [String] mode Le mode de jeu dans lequel a été réalisé le score.
    # @param [Integer] tempsPartiel Le temps lier à la grille.
    # @param [Integer] malus Temps de malus sur la grille.
    # @param [Integer] taille_grille La taille de la grille sur laquelle à été réalisé le score.
    # @param [Integer] numero_grille Le numéro de la grille sur laquelle à été réalisé le score.
    #
    # @return idScore Identifiant du score qui vient d'être inséré.
    def ajouterScore(id_joueur, mode, tempsPartiel, malus, taille_grille, numero_grille)
        idScore = nil

        idGrille = ajouterGrille(taille_grille, numero_grille)

        begin

            idScore = FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO score(id_grille, modeJeu_score, tempsBrut_score, malus_score, id_joueur) VALUES (#{idGrille}, '#{mode}', #{tempsPartiel}, #{malus}, #{id_joueur})")

        rescue SQLite3::Exception => e
            # Comme il y a un eu un probleme lors de l'insertion d'au moins un score pour la grille alors on indique une erreur et on supprime la grille qui a été specialement créée pour le score.
            supprimerGrille(idGrille)
            puts "Exception occurred"
            puts e

            return
        end
      	return idScore
    end
    # Méthode permettant de récupérer les scores d'un joueur précis.
    # @param [Integer] id_joueur Identifiant du joueur concerné.
    # @param [Array] conditions Liste des conditions à mettre après le where
  	# @param [Array] orderConditions Condition d'ordre, à mettre après le group by
  	# @param [String] orderPosition Score par ordre ASC ou DESC
    def recupererScore(id_joueur, conditions, orderConditions=[], orderPosition = "ASC")
      orderCondition = "" # Variable contenant la condition finale SQL.
      condition = ""

      # Pour toutes les conditions données en paramètre, les mettre en forme pour la requête SQL.
      if (orderConditions.size() > 0)
        orderConditions.each do |value|
          orderCondition += value + ", "
        end
      end

      if (conditions.size() > 0)
        conditions.each do |key, array|
          condition += " AND " + key.to_s + " = " + array.to_s
        end
      end

      results = FournisseurBaseDeDonnees.executerSQL("SELECT modeJeu_score, tempsBrut_score, malus_score, taille_grille, numero_grille, tempsBrut_score + malus_score AS score_total FROM score JOIN grille ON score.id_grille=grille.id_grille WHERE id_joueur=#{id_joueur} " + condition +  " ORDER BY " + orderCondition + " numero_grille, score_total " + orderPosition)

      # Création d'une hash map pour que les données soit associées à leur colonne.
      hash = []
      results.each do |result|
        hash.push({ "modeJeu_score" => result[0], "tempsBrut_score" => result[1], "malus_score" => result[2], "taille_grille" => result[3], "numero_grille" => result[4]})
      end
      return hash
    end

    # Méthode permettant de récupérer les scores en fonction de leur MODE, TAILLE de grille et NUMERO de grille.
    #
    # @param [Integer] id_joueur Identifiant du joueur concerné
    # @param [String] mode Mode de jeu
    # @param [Integer] taille Taille de grille
    # @param [Integer] numero Numéro de grille (Optionnel)
    def scoreModeTailleNumero(id_joueur, mode, taille, numero=nil)
      params = nil
      if (numero != nil)
        params = [["modeJeu_score", "\"" + mode + "\""],["taille_grille", taille],["numero_grille", numero]]
      else
        params = [["modeJeu_score", "\"" + mode + "\""],["taille_grille", taille]]
      end
      return recupererScore(id_joueur, params)
    end


    # Méthode permettant d'ajouter une grille.
    #
    # @param [Integer] taille_grille Taille de la grille à ajouter
    # @param [Integer] numero_grille Numéro de la grille à ajouter
    #
    # @return idGrille Identifiant de la grille qui vient d'être insérée.
  	def ajouterGrille(taille_grille, numero_grille)
      idGrille = nil
      begin

            idGrille = FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO grille(contenu_grille, taille_grille , numero_grille) VALUES (NULL,#{taille_grille},#{numero_grille})")

        rescue SQLite3::Exception => e
            / Show a Popup /

            puts "Exception occurred"
            puts e

            return
        end
      	return idGrille
    end

  	# Méthode permettant de supprimer une grille par son identifiant.
    #
    # @param [Integer] id_grille L'identifiant de la grille à supprimer.
    def supprimerGrille(id_grille)
        FournisseurBaseDeDonnees.executerSQL("DELETE FROM grille WHERE id_grille=#{id_grille}")
    end

    # Méthode permettant d'ajouter une sauvegarde.
    #
    # @param [Integer] id_joueur Identifiant du joueur possesseur de la sauvegarde
    # @param [Integer] taille Taille de la grille pour la sauvegarde
    # @param [Integer] numero Numéro de la grille pour la sauvegarde
    # @param [String] filename Numero du fichier de la sauvegarde
    #
    # @return id_sauvegarde Identifiant de la sauvegarde qui vient d'être insérée.
  	def ajouterSauvegarde(id_joueur, taille, numero, filename)
      id_sauvegarde = nil
      begin
          id_sauvegarde = FournisseurBaseDeDonnees.executerInsertSQL("INSERT INTO sauvegarde_partie(filename, id_joueur, taille, numero) VALUES ('#{filename}', #{id_joueur}, #{taille}, #{numero})")
      rescue SQLite3::Exception => e
          return
      end
      return id_sauvegarde
    end

    def sauvegardesJoueur(id_joueur)
      sauvegardes = FournisseurBaseDeDonnees.executerSQL("SELECT taille, numero, filename FROM sauvegarde_partie WHERE id_joueur=#{id_joueur}")
      hash = []
      sauvegardes.each do |sauvegarde|
        hash.push({"taille" => sauvegarde[0], "numero" => sauvegarde[1], "filename" => sauvegarde[2]})
      end
      return hash
    end

    # Méthode permettant de supprimer une sauvegarde par son identifiant.
    #
    # @param [Integer] id_sauvegarde_partie L'identifiant de la sauvegarde à supprimer
    def supprimerSauvegarde(id_joueur, taille, numero)
		  FournisseurBaseDeDonnees.executerSQL("DELETE FROM sauvegarde_partie WHERE id_joueur=#{id_joueur} AND taille=#{taille} AND numero=#{numero}")
    end

    # Méthode permettant de récupérer les classements.
    # @param [Array] conditions Liste des conditions à mettre après le where
    # @param [Array] orderConditions Condition d'ordre, à mettre après le group by
    # @param [String] orderPosition Score par ordre ASC ou DESC
    def classement(conditions, orderConditions=[], orderPosition = "ASC")
      orderCondition = "" # Variable contenant la condition finale SQL.
      condition = ""

      # Pour toutes les conditions données en paramètre, les mettre en forme pour la requête SQL.
      if (orderConditions.size() > 0)
        orderConditions.each do |key, array|
          orderCondition += key + " " + array + ", "
        end
      end

      if (conditions.size() > 0)
        conditions.each do |key, array|
          condition += " AND " + key.to_s + " = " + array.to_s
        end
      end
      results = FournisseurBaseDeDonnees.executerSQL("SELECT id_score AS id, joueur.id_joueur, joueur.pseudo_joueur, joueur.cagnotte_joueur, taille_grille, numero_grille, modeJeu_score, tempsBrut_score, malus_score , MIN(tempsBrut_score + malus_score) as total
					FROM score JOIN joueur ON score.id_joueur = joueur.id_joueur JOIN grille ON score.id_grille = grille.id_grille" + condition + "  GROUP BY grille.numero_grille, joueur.id_joueur
            ORDER BY " + orderCondition + " numero_grille, score.tempsBrut_score " + orderPosition)

      # Création d'une hash map pour que les données soient associées à leur colonne.
      hash = []
      results.each do |result|
        hash.push({"id" => result[0], "id_joueur" => result[1], "pseudo_joueur" => result[2], "cagnotte_joueur" => result[3], "taille_grille" => result[4], "numero_grille" => result[5], "modeJeu_score" => result[6], "tempsBrut_score" => result[7], "malus_score" => result[8]})
      end
      return hash
    end

    # Méthode permettant de récupérer les classements en fonction de leur MODE, TAILLE de grille et NUMERO de grille.
    #
    # @param [String] mode Mode de jeu
    # @param [Integer] taille Taille de grille
    # @param [Integer] numero Numéro de grille (Optionnel)
    def classementModeTailleNumero(mode, taille, numero=nil)
      params = nil
      if (numero != nil)
        params = [["modeJeu_score", "\"" + mode + "\""],["taille_grille", taille],["numero_grille", numero]]
      else
        params = [["modeJeu_score", "\"" + mode + "\""],["taille_grille", taille]]
      end
      return classement(params, [], "ASC")
    end

  	# Méthode permettant de trier les classements par nom croissant.
  	def classementParNomCroissant()
      	return classement([], [["pseudo_joueur", "ASC"]])
    end

  	# Méthode permettant de trier les classements par nom décroissant.
  	def classementParNomDecroissant()
      	return classement([], [["pseudo_joueur", "DESC"]])
    end

  	# Méthode permettant de trier les classements par score croissant.
  	def classementParScoreCroissant()
      	return classement([], [["tempsBrut_score+malus_score", "ASC"]])
    end

  	# Méthode permettant de trier les classements par score décroissant.
    def classementParScoreDecroissant()
      	return classement([], [["tempsBrut_score+malus_score", "DESC"]])
    end

  	# Méthode permettant de trier les classements par position croissante.
  	def classementParPositionCroissante()
      	return classementParScoreCroissant()
    end

  	# Méthode permettant de trier les classements par position décroissante.
    def classementParPositionDecroissante()
      	return classementParScoreDecroissant()
    end

  	# Méthode permettant de trier les classements par taille de grille croissante.
  	def classementParTailleGrilleCroissante()
      	return classement([], [["taille_grille", "ASC"]])
    end

  	# Méthode permettant de trier les classements par taille de grille décroissante.
    def classementParTailleGrilleDecroissante()
      	return classement([], [["taille_grille", "DESC"]])
    end

  	# Méthode permettant de trier les classements par numéro de grille croissant.
  	def classementParNumeroGrilleCroissant()
      	return classement([], [["numero_grille", "ASC"]])
    end

  	# Méthode permettant de trier les classements par numéro de grille décroissant.
    def classementParNumeroGrilleDecroissant()
      	return classement([], [["numero_grille", "DESC"]])
    end

    # Méthode permettant de récupérer le nombre de grilles debloquées pour une taille, un mode et un joueur précis.
    #
    # @param [Integer] id_joueur L'identifiant du joueur concerné
    # @param [Integer] taille_grille Taille de la grille
    # @param [String] mode Mode concerné
    def recupererNbGrilleDebloquee(id_joueur, taille_grille, mode)
      results = FournisseurBaseDeDonnees.executerSQL("SELECT COUNT(DISTINCT(grille.numero_grille)) AS nb_debloque, CASE WHEN estDeverrouille is NULL THEN (SELECT estDeverrouille FROM dimension_grille WHERE taille=#{taille_grille} AND id_joueur=#{id_joueur}) ELSE estDeverrouille END AS estDeverrouille, CASE WHEN cout is NULL THEN (SELECT cout FROM dimension_grille WHERE taille=#{taille_grille} AND id_joueur=#{id_joueur}) ELSE cout END AS cout FROM grille JOIN score ON grille.id_grille=score.id_grille JOIN joueur ON score.id_joueur=joueur.id_joueur JOIN dimension_grille ON joueur.id_joueur=dimension_grille.id_joueur AND grille.taille_grille=dimension_grille.taille WHERE modeJeu_score=\"#{mode}\" AND joueur.id_joueur=#{id_joueur} AND taille_grille=#{taille_grille}")
       # Création d'une hash map pour que les données soient associées à leur colonne.
       hash = []
       results.each do |result|
         hash.push({"nb_debloque" => result[0], "estDeverrouille" => result[1], "cout" => result[2]})
       end
       return hash
    end

    # Méthode permettant de déverrouiller une dimension de grille
    #
    # @param [Integer] id_joueur L'identifiant du joueur concerné
    # @param [Integer] taille_grille Taille des grilles déverrouillées
    def deverrouillerDimensionGrille(id_joueur, taille_grille)
      FournisseurBaseDeDonnees.executerSQL("UPDATE dimension_grille SET estDeverrouille=1 WHERE id_joueur=#{id_joueur} AND taille=#{taille_grille}")
    end

    # Méthode permettant de récupérer les grilles pour une taille, un mode et un joueur précis.
    #
    # @param [Integer] id_joueur L'identifiant du joueur concerné
    # @param [Integer] taille_grille Taille de la grille
    # @param [String] mode Mode concerné
    def recupererGrilleParTaille(id_joueur, taille_grille, mode)
      results = FournisseurBaseDeDonnees.executerSQL("SELECT numero_grille, MIN(tempsBrut_score + malus_score) AS score FROM score JOIN grille ON grille.id_grille=score.id_grille WHERE modeJeu_score=\"#{mode}\" AND taille_grille=#{taille_grille} AND id_joueur=#{id_joueur} GROUP BY numero_grille ORDER BY numero_grille")
      # Création d'une hash map pour que les données soient associées à leur colonne.
      hash = []
      results.each do |result|
        hash.push({"numero_grille" => result[0], "score" => result[1]})
      end
      return hash
    end

    # Méthode permettant de récuperer le temps maximum d'une dimension de grille.
    #
    # @param [Integer] taille_grille Taille de la grille concernée
    def recupererTempsMax(taille_grille)
      return FournisseurBaseDeDonnees.executerSQL("SELECT tempsMax FROM dimension_grille WHERE taille=#{taille_grille}")[0][0]
    end

  	# Méthode permettant de fermer l'accès à la base de données.
    def fermerBaseDeDonnees()
      FournisseurBaseDeDonnees.fermerBaseDeDonnees()
    end
end
