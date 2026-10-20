# TP Jour 3 — Réponses aux questions de compréhension

## 1. Pourquoi changer le port force-t-il la recréation du conteneur ?

Docker ne permet pas de modifier les ports publiés d'un conteneur existant : le mapping
de ports est fixé à la création du conteneur. Le provider `kreuzwerker/docker` marque donc
l'attribut `ports` comme *ForceNew*, et `terraform plan` l'indique explicitement :
`~ external = 8080 -> 8081 # forces replacement` → symbole `-/+`.
L'image et le réseau ne font pas référence à `var.external_port` : rien ne change pour eux,
Terraform ne les touche pas (`Plan: 1 to add, 0 to change, 1 to destroy`).

## 2. Qu'est-ce qui indique que `docker_container.web` dépend de `docker_network.tp3_net` ?

La référence `name = docker_network.tp3_net.name` dans le bloc `networks_advanced` du
conteneur (de même que `image = docker_image.nginx.image_id` pour l'image).
Aucune dépendance n'a été déclarée explicitement (pas de `depends_on`) : Terraform déduit
ces dépendances **implicites** des références entre ressources. Extrait de `terraform graph` :

```
"docker_container.web" -> "docker_image.nginx";
"docker_container.web" -> "docker_network.tp3_net";
```

## 3. Pourquoi le pipeline exécute-t-il `terraform validate` plutôt que `terraform apply` ?

Les runners partagés de GitLab s'exécutent dans le cloud de GitLab, sans aucun accès au
Docker Desktop local : un `apply` ne pourrait rien provisionner. Le rôle du pipeline ici est
de vérifier automatiquement la qualité du code (formatage avec `fmt -check`, syntaxe et
références avec `validate`) à chaque push, sans risque de modifier une infrastructure.
En conditions réelles, l'`apply` est lancé depuis un runner disposant des identifiants
nécessaires, généralement après validation manuelle du plan.

## 4. Pourquoi `APP_ENV` est-elle définie dans l'interface GitLab ?

Pour séparer la configuration du code : la valeur peut changer selon l'environnement sans
modifier ni recommitter le code, et une valeur sensible n'apparaît pas dans le dépôt.
Écrite en clair dans `.gitlab-ci.yml`, elle serait versionnée dans l'historique Git, visible
par toute personne ayant accès au dépôt (impossible à effacer proprement si c'était un
secret), et la changer imposerait un nouveau commit.
