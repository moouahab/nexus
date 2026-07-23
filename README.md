# Nexus

Nexus est une plateforme cross-platform conçue pour présenter des projets, des compétences et une méthode de travail de manière plus complète qu’un portfolio classique.

Le projet prévoit également, à terme, un assistant intelligent capable d’aider un client à structurer son idée, proposer une architecture technique, estimer la complexité du projet et générer un pré-devis.

Le frontend est développé avec Flutter. Le backend est organisé en microservices indépendants. Un API Gateway sert de point d’entrée unique entre le frontend et les services backend.

---

## Objectif actuel

Le projet est encore dans sa phase de fondation.

L’objectif immédiat n’est pas de construire toute la plateforme, mais de valider progressivement l’architecture suivante :

```text
Frontend Flutter
       |
       v
API Gateway
       |
       +------------------+
       |                  |
       v                  v
Identity Service     Projects Service
       |                  |
       v                  v
 Identity DB          Projects DB
```

Le développement se fait étape par étape.

La première priorité est le service d’identité.

---

## Structure du projet

```text
nexus/
├── backend/
│   └── services/
│       ├── identity/
│       │   ├── identity_client/
│       │   └── identity_server/
│       │
│       └── projects/
│           ├── projects_client/
│           └── projects_server/
│
├── frontend/
│   └── app/
│
├── gateway/
│
├── .gitignore
└── README.md
```

### `backend/services`

Ce dossier contient les microservices backend.

Chaque service doit être indépendant et posséder :

- sa propre logique métier ;
- ses propres endpoints ;
- sa propre configuration ;
- sa propre base de données ;
- ses propres migrations ;
- ses propres tests ;
- son propre conteneur Docker.

### `frontend/app`

Ce dossier contient l’unique application Flutter du projet.

Le frontend ne doit pas appeler directement les microservices.

Il communique uniquement avec l’API Gateway.

### `gateway`

Le Gateway est placé à la racine car il sert de pont entre le frontend et les services backend.

Son rôle sera de gérer :

- le routage des requêtes ;
- HTTPS ;
- le contrôle des accès ;
- CORS ;
- le rate limiting ;
- les journaux d’accès ;
- la protection des services internes.

---

# Services backend

## Identity Service

Chemin :

```text
backend/services/identity/
```

Le service Identity est responsable de l’identité et de l’authentification.

Il devra gérer :

- l’inscription ;
- la connexion ;
- la déconnexion ;
- les sessions ;
- les jetons JWT ;
- les refresh tokens ;
- la récupération de compte ;
- les secrets liés à l’authentification ;
- les contrôles d’accès ;
- éventuellement l’authentification multifacteur.

Structure :

```text
identity/
├── identity_client/
└── identity_server/
```

### `identity_server`

C’est le vrai microservice exécuté sur le serveur.

Il contient notamment :

```text
identity_server/
├── bin/
│   └── main.dart
├── config/
│   ├── development.yaml
│   ├── test.yaml
│   ├── staging.yaml
│   ├── production.yaml
│   ├── generator.yaml
│   └── passwords.yaml
├── lib/
├── migrations/
├── test/
├── Dockerfile
└── docker-compose.yaml
```

### `identity_client`

Ce dossier n’est pas un microservice.

C’est une bibliothèque Dart générée par Serverpod.

Elle contient :

- les modèles partagés ;
- les contrats d’API ;
- les méthodes utilisées par Flutter pour appeler le service ;
- la sérialisation des données.

---

## Projects Service

Chemin :

```text
backend/services/projects/
```

Le service Projects sera responsable des projets présentés dans Nexus.

Il devra gérer :

- la création d’un projet ;
- la modification d’un projet ;
- la suppression d’un projet ;
- la publication ou le masquage ;
- le titre ;
- la description ;
- les objectifs ;
- les technologies utilisées ;
- les difficultés rencontrées ;
- les solutions apportées ;
- les résultats ;
- les liens de démonstration ;
- les liens GitHub ou GitLab.

Ce service sera développé après la validation complète du service Identity.

---

# Configuration Serverpod

Chaque microservice Serverpod contient plusieurs fichiers de configuration.

## `development.yaml`

Utilisé pour le développement local.

Exemple de lancement :

```bash
dart bin/main.dart --mode=development
```

Il contient notamment :

- les ports internes ;
- l’adresse de la base de données locale ;
- le nom de la base ;
- les options utilisées pendant le développement.

## `test.yaml`

Utilisé pour les tests automatisés.

Il doit utiliser une base de données séparée.

Les tests ne doivent jamais être exécutés sur la base de développement ou de production.

## `staging.yaml`

Utilisé pour l’environnement de préproduction.

Le staging permet de valider :

- une nouvelle version ;
- les migrations ;
- l’intégration entre les services ;
- la configuration du Gateway ;
- le déploiement avant production.

## `production.yaml`

Utilisé sur l’environnement réel.

La production utilisera :

- HTTPS ;
- des secrets externes ;
- une base dédiée ;
- des logs contrôlés ;
- des règles réseau strictes ;
- des sauvegardes ;
- de la supervision.

## `generator.yaml`

Ce fichier sert à la génération du code Serverpod.

Commande :

```bash
serverpod generate
```

Il ne contient pas la configuration réseau ou les secrets.

## `passwords.yaml`

Ce fichier contient les secrets utilisés par Serverpod.

Il peut contenir :

- le mot de passe PostgreSQL ;
- le secret de communication entre serveurs ;
- la clé de signature JWT ;
- les peppers de hachage ;
- les secrets Redis.

Ce fichier ne doit jamais être envoyé sur Git.

---

# Sécurité

La sécurité doit être intégrée dès le début du projet.

## Principe réseau

Aucun microservice ni aucune base de données ne devra être directement accessible depuis Internet.

Architecture prévue :

```text
Internet
   |
   | HTTPS 443
   v
API Gateway
   |
   +--> Identity Service
   |
   +--> Projects Service
```

Seul le Gateway devra être exposé publiquement.

Les services internes communiqueront sur des réseaux privés.

## Ports

En production :

- le Gateway publiera le port `443` ;
- les microservices utiliseront des ports internes ;
- PostgreSQL restera privé ;
- Redis restera privé ;
- l’interface d’administration du Gateway restera privée ;
- Serverpod Insights restera privé.

## Secrets

Les secrets ne doivent jamais être écrits directement dans le code.

À terme, Nexus utilisera :

- des variables d’environnement pour le développement ;
- Vault pour les secrets ;
- éventuellement un HSM pour les clés les plus sensibles.

## Fichiers à ne jamais envoyer sur Git

```gitignore
**/config/passwords.yaml
.env
*.env
gateway/certs/*
```

---

# Git

Le dépôt Git n’est pas encore initialisé.

Avant de lancer `git init`, vérifier que le fichier `.gitignore` contient au minimum :

```gitignore
# Secrets Serverpod
**/config/passwords.yaml
.env
*.env

# Certificats privés
gateway/certs/*
!gateway/certs/.gitkeep

# Dart et Flutter
.dart_tool/
build/
.pub/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.idea/
.vscode/
*.iml

# Système
.DS_Store
```

Initialisation future :

```bash
cd ~/nexus
git init
git add .
git status
```

Avant le premier commit, vérifier que les fichiers `passwords.yaml` ne sont pas suivis.

---

# Workflow de développement

Le travail doit être réalisé dans cet ordre :

```text
1. Construire un service
2. Configurer sa base
3. Ajouter ses modèles
4. Ajouter ses endpoints
5. Ajouter la validation
6. Ajouter les tests
7. Ajouter les logs
8. Ajouter la sécurité
9. Conteneuriser le service
10. Valider le service
11. Passer au service suivant
```

Pour le moment, le projet se concentre uniquement sur :

```text
Identity Service
```

Le Gateway, le frontend et Projects seront raccordés après validation du service Identity.

---

# Commandes utiles

## Se placer dans Identity

```bash
cd ~/nexus/backend/services/identity/identity_server
```

## Afficher la configuration de développement

```bash
sed -n '1,220p' config/development.yaml
```

## Vérifier la structure des secrets sans afficher leurs valeurs

```bash
sed -E 's/: .+/: [MASQUÉ]/' config/passwords.yaml
```

## Générer le code Serverpod

```bash
serverpod generate
```

## Créer une migration

```bash
serverpod create-migration
```

## Démarrer le serveur en développement

```bash
dart bin/main.dart --mode=development
```

## Appliquer les migrations

```bash
dart bin/main.dart --mode=development --apply-migrations
```

## Lancer les tests

```bash
dart test
```

---

# Roadmap

## Phase 1 — Identity Service

- configuration locale ;
- base PostgreSQL dédiée ;
- endpoints de santé ;
- inscription ;
- connexion ;
- JWT ;
- refresh token ;
- validation ;
- tests ;
- logs ;
- Docker.

## Phase 2 — Projects Service

- modèle Project ;
- CRUD ;
- publication ;
- technologies ;
- liens de démonstration ;
- validation ;
- tests ;
- Docker.

## Phase 3 — API Gateway

- routage ;
- HTTPS ;
- CORS ;
- rate limiting ;
- contrôle des tokens ;
- logs ;
- réseaux privés.

## Phase 4 — Frontend Flutter

- connexion au Gateway ;
- écran de connexion ;
- écran de test des services ;
- affichage des projets ;
- gestion des erreurs backend.

## Phase 5 — Infrastructure

Lorsque l’architecture locale sera validée :

- Terraform pour créer l’infrastructure ;
- Ansible pour configurer les serveurs ;
- K3s ou Kubernetes pour orchestrer les services ;
- Vault pour gérer les secrets ;
- Prometheus et Grafana pour la supervision.

---

# Règles du projet

1. Un service doit avoir une responsabilité claire.
2. Un service ne doit pas accéder directement à la base d’un autre service.
3. Le frontend ne doit pas appeler directement les services.
4. Le Gateway est le seul point d’entrée public.
5. Les bases de données restent privées.
6. Les secrets ne doivent jamais être versionnés.
7. Toute nouvelle fonctionnalité doit avoir des tests.
8. Les migrations doivent être versionnées.
9. Les erreurs doivent être contrôlées.
10. Chaque service doit pouvoir être déployé indépendamment.

---

# État actuel

```text
[OK] Frontend Flutter créé
[OK] Identity Service généré
[OK] Projects Service généré
[OK] Dossier Gateway créé
[OK] Secrets Serverpod générés
[À FAIRE] Configurer Identity
[À FAIRE] Démarrer Identity
[À FAIRE] Tester Identity
[À FAIRE] Conteneuriser Identity
[À FAIRE] Configurer le Gateway
[À FAIRE] Connecter Flutter
```

---

## Licence

Projet personnel en cours de développement.
