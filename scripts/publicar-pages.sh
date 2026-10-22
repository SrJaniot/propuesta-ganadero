#!/usr/bin/env sh
# PUBLICA LA PROPUESTA EN GITHUB PAGES (https://srjaniot.github.io/propuesta-ganadero/)
# 1. CREA EL REPO PUBLICO SrJaniot/propuesta-ganadero SI NO EXISTE (API DE GITHUB CON LA CREDENCIAL DE GIT DEL PC, SIN MOSTRAR EL TOKEN)
# 2. SUBE EL CODIGO A main
# 3. ACTIVA GITHUB PAGES SOBRE main EN LA RAIZ (SOLO LA PRIMERA VEZ)
# USO (DESDE LA CARPETA DE LA PROPUESTA): sh scripts/publicar-pages.sh
set -e
USUARIO=SrJaniot
REPO=propuesta-ganadero
API=https://api.github.com
cd "$(dirname "$0")/.."

TOKEN=$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill 2>/dev/null | sed -n 's/^password=//p')
if [ -z "$TOKEN" ]; then echo "No encontre la credencial de GitHub en git"; exit 1; fi

#PASO 1: EL REPO
CODIGO=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $TOKEN" "$API/repos/$USUARIO/$REPO")
if [ "$CODIGO" = "404" ]; then
  curl -s -o /dev/null -w "Repo creado: %{http_code}\n" -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
    "$API/user/repos" -d "{\"name\":\"$REPO\",\"description\":\"Propuesta: gestion ganadera de doble proposito que funciona sin internet\",\"private\":false,\"has_wiki\":false}"
else
  echo "El repo ya existe ($CODIGO)"
fi

#PASO 2: EL CODIGO
git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$USUARIO/$REPO.git"
git push -u origin main

#PASO 3: ACTIVAR PAGES (SI YA ESTA ACTIVO RESPONDE 409 Y NO PASA NADA)
curl -s -o /dev/null -w "Pages: %{http_code}\n" -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
  "$API/repos/$USUARIO/$REPO/pages" -d '{"source":{"branch":"main","path":"/"}}'
unset TOKEN
echo "Listo: https://srjaniot.github.io/$REPO/ (puede tardar 1 o 2 minutos la primera vez)"
