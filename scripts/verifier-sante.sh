#!/bin/bash
# Vérifie la santé de tous les services de la pile XeuySil

SERVICES=("http://localhost:8080/api/v1/settings/public" "http://localhost:8080/nginx-health" "http://localhost:8080")
NOMS=("Serveur (API)" "Nginx (proxy)" "Client (web)")
MAX_TENTATIVES=10
DELAI=5
ECHECS=0

echo "=== Vérification de santé de la pile XeuySil ==="
echo ""

for i in "${!SERVICES[@]}"; do
    URL="${SERVICES[$i]}"
    NOM="${NOMS[$i]}"
    SUCCES=false

    for tentative in $(seq 1 $MAX_TENTATIVES); do
        CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null)
        if [ "$CODE" -ge 200 ] && [ "$CODE" -lt 400 ]; then
            echo "[OK] $NOM — HTTP $CODE"
            SUCCES=true
            break
        fi
        echo "[ATTENTE] $NOM — tentative $tentative/$MAX_TENTATIVES (HTTP $CODE)..."
        sleep $DELAI
    done

    if [ "$SUCCES" = false ]; then
        echo "[ECHEC] $NOM ne répond pas après $MAX_TENTATIVES tentatives"
        ECHECS=$((ECHECS + 1))
    fi
done

echo ""
if [ $ECHECS -eq 0 ]; then
    echo "=== Tous les services sont opérationnels ==="
    exit 0
else
    echo "=== $ECHECS service(s) en échec ==="
    exit 1
fi
