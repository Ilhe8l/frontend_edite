#!/bin/bash

# Script para testar conexão com Django API

echo "🔍 Testando Conexão com Django API"
echo "=================================="
echo ""

# URL base da API
API_URL="https://controlpanel.aws.leds.dev.br/api"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para testar endpoint
test_endpoint() {
    local endpoint=$1
    local method=$2
    local description=$3
    
    echo -n "Testando $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -X $method "$API_URL$endpoint" 2>&1)
    
    if [ $? -eq 0 ]; then
        if [ "$response" == "200" ] || [ "$response" == "401" ]; then
            echo -e "${GREEN}✓${NC} (HTTP $response)"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} (HTTP $response)"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} (Erro de conexão)"
        return 2
    fi
}

# Verificar se está conectado à VPN
echo "1. Verificando conectividade..."
echo ""

if ping -c 1 -W 2 controlpanel.aws.leds.dev.br &> /dev/null; then
    echo -e "${GREEN}✓${NC} Servidor acessível"
else
    echo -e "${RED}✗${NC} Servidor não acessível"
    echo ""
    echo "⚠️  Certifique-se de estar conectado à VPN!"
    exit 1
fi

echo ""
echo "2. Testando endpoints da API..."
echo ""

# Testar endpoints
test_endpoint "/editals/" "GET" "Listagem de Editais"
test_endpoint "/metrics/engagement/" "GET" "Métricas de Engajamento"
test_endpoint "/metrics/messages/" "GET" "Listagem de Mensagens"
test_endpoint "/history/sessions/" "GET" "Histórico de Sessões"
test_endpoint "/auth/login/" "POST" "Endpoint de Login"

echo ""
echo "3. Testando CORS..."
echo ""

# Testar CORS
cors_test=$(curl -s -I -X OPTIONS "$API_URL/editals/" \
    -H "Origin: http://localhost:3000" \
    -H "Access-Control-Request-Method: GET" 2>&1)

if echo "$cors_test" | grep -q "Access-Control-Allow-Origin"; then
    echo -e "${GREEN}✓${NC} CORS configurado corretamente"
else
    echo -e "${RED}✗${NC} CORS não configurado"
    echo ""
    echo "⚠️  Configure CORS no Django (veja DJANGO_CHECKLIST.md)"
fi

echo ""
echo "=================================="
echo "Teste concluído!"
echo ""

# Instruções finais
echo "📝 Próximos passos:"
echo ""
echo "1. Se todos os testes passaram:"
echo "   ./switch-mode.sh vpn"
echo "   npm run dev"
echo ""
echo "2. Se algum teste falhou:"
echo "   - Verifique se está conectado à VPN"
echo "   - Consulte DJANGO_CHECKLIST.md"
echo "   - Verifique os logs do Django"
echo ""
