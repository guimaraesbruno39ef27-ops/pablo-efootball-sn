PABLO eFOOTBALL SN — captures et contestations v0.4

1. Dans Supabase > SQL Editor, exécute migration_v0.4.sql après le schéma de la version précédente.
2. Renseigne config.js avec l’URL du projet et la clé publique anon/publishable.
3. Héberge index.html, config.js et les autres fichiers du starter en HTTPS.
4. Un joueur doit joindre une capture JPG/PNG/WebP de 5 Mo maximum pour soumettre un score.
5. Les contestations doivent concerner un match auquel le joueur a participé; un administrateur peut résoudre ou rejeter la contestation.

Le bucket match-proofs est privé. Les captures ne sont pas publiquement accessibles. Cette version enregistre les chemins des preuves, mais l’affichage direct des images via URL signée et l’audit détaillé des décisions doivent être ajoutés/testés avant une ouverture publique. Vérifie les politiques RLS sur un projet de test. Ne place jamais la clé service_role dans le navigateur. Les captures d’écran ne sont pas automatiquement authentifiées par les serveurs eFootball : l’arbitre doit les vérifier.
