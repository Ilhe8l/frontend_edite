#!/bin/bash

echo "🔍 Testando Django Control Panel"
echo "=================================="
echo ""

API_URL="https://controlpanel.aws.leds.dev.br"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "1. Testando conectividade..."
echo ""

if curl -s -o /dev/null -w "%{http_code}" "$API_URL/admin/" | grep -q "302\|200"; then
    echo -e "${GREEN}✓${NC} Django acessível em $API_URL"
else
    echo -e "${RED}✗${NC} Django não acessível"
    echo "Certifique-se de estar conectado à VPN!"
    exit 1
fi

echo ""
echo "2. Descobrindo endpoints..."
echo ""

# Testar endpoints comuns
echo -e "${BLUE}Testando endpoints de autenticação:${NC}"

endpoints=(
    "/api/auth/login/"
    "/api/token/"
    "/api/token/obtain/"
    "/api/login/"
    "/auth/login/"
    "/api/v1/auth/login/"
)

for endpoint in "${endpoints[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL$endpoint" 2>&1)
    if [ "$response" != "404" ]; then
        echo -e "  ${GREEN}✓${NC} $endpoint (HTTP $response)"
    fi
done

echo ""
echo -e "${BLUE}Testando endpoints de editais:${NC}"

endpoints=(
    "/api/editals/"
    "/api/edital/"
    "/api/editais/"
    "/api/v1/editals/"
)

for endpoint in "${endpoints[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL$endpoint" 2>&1)
    if [ "$response" != "404" ]; then
        echo -e "  ${GREEN}✓${NC} $endpoint (HTTP $response)"
    fi
done

echo ""
echo -e "${BLUE}Testando endpoints de mensagens:${NC}"

endpoints=(
    "/api/messages/"
    "/api/mensagens/"
    "/api/discussao/mensagens/"
    "/api/metrics/messages/"
)

for endpoint in "${endpoints[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL$endpoint" 2>&1)
    if [ "$response" != "404" ]; then
        echo -e "  ${GREEN}✓${NC} $endpoint (HTTP $response)"
    fi
done

echo ""
echo -e "${BLUE}Testando endpoints de conversas:${NC}"

endpoints=(
    "/api/conversations/"
    "/api/conversas/"
    "/api/discussao/conversas/"
    "/api/history/sessions/"
)

for endpoint in "${endpoints[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL$endpoint" 2>&1)
    if [ "$response" != "404" ]; then
        echo -e "  ${GREEN}✓${NC} $endpoint (HTTP $response)"
    fi
done

echo ""
echo "=================================="
echo ""
echo "📝 Próximos passos:"
echo ""
echo "1. Configure CORS no Django (veja INTEGRACAO_RAPIDA.md)"
echo "2. Me diga quais endpoints existem (os marcados com ✓)"
echo "3. Vou adaptar o frontend para usar esses endpoints"
echo ""
