# Garde-fous pour utiliser un assistant de code en équipe

Liste issue d'un usage quotidien de Claude Code. Chaque ligne vient d'un incident : adaptez-la, ne la copiez pas à l'aveugle.

## Vérification
- [ ] Avant de relayer un numéro de ligne, un statut ("tout est corrigé") ou une indisponibilité d'outil annoncés par un sous-agent, rouvrir le fichier ou l'objet concerné.
- [ ] Citer la source de chaque affirmation dans un commentaire de PR ou un ticket : vérifiée (avec la source) ou non vérifiée.

## Coût et contexte
- [ ] Modèle par défaut intermédiaire. Petit modèle pour la recherche, la lecture et la synthèse. Modèle le plus puissant uniquement sur demande explicite.
- [ ] Fichier de consignes court : il est chargé à chaque session. Les tables de routage et les détails vont dans des pages lues à la demande.
- [ ] Chercher (grep) avant de lire un gros fichier, puis lire seulement la plage utile.

## Règles qui doivent toujours s'appliquer
- [ ] Une règle qui ne doit jamais être oubliée va dans un hook ou dans la CI, pas dans un prompt.
- [ ] Une convention de code vérifiable par un motif devient une règle de lint, appliquée en pre-commit et en CI.
- [ ] Ne pas s'appuyer sur le mode automatique pour une règle de sécurité : sa décision peut varier d'une session à l'autre.

## Autonomie
- [ ] Lire, chercher, analyser : seul.
- [ ] Modifier du code : seul, vérifié par les tests et la CI.
- [ ] Publier, envoyer, pousser, supprimer : après validation explicite.
- [ ] Commentaires de PR et de tickets : montrés avant publication.

## Mémoire
- [ ] Un wiki en markdown, une page par domaine, un index.
- [ ] N'y mettre que des faits vérifiés, implémentés ou testés. Jamais d'hypothèses.
- [ ] Si le code contredit une page, le code gagne : corriger la page.
