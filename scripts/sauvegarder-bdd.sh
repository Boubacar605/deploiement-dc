#!/bin/bash
# Sauvegarde de la base de données PostgreSQL de XeuySil

REPERTOIRE_SAUVEGARDES="./sauvegardes"
HORODATAGE=$(date +"%Y%m%d_%H%M%S")
FICHIER="$REPERTOIRE_SAUVEGARDES/xeuysil_$HORODATAGE.sql.gz"

mkdir -p "$REPERTOIRE_SAUVEGARDES"

echo "Sauvegarde de la base de données..."
docker compose exec -T postgres pg_dump -U "${POSTGRES_USER:-xeuysil}" "${POSTGRES_DB:-xeuysil}" | gzip > "$FICHIER"

if [ $? -eq 0 ]; then
    TAILLE=$(du -h "$FICHIER" | cut -f1)
    echo "Sauvegarde réussie : $FICHIER ($TAILLE)"

    # Suppression des sauvegardes de plus de 7 jours
    find "$REPERTOIRE_SAUVEGARDES" -name "*.sql.gz" -mtime +7 -delete
    echo "Anciennes sauvegardes nettoyées (rétention : 7 jours)"
else
    echo "Erreur lors de la sauvegarde"
    rm -f "$FICHIER"
    exit 1
fi
