#!/bin/bash

# Script para verificar quais endpoints do Django já existem

echo "🔍 Verificando Endpoints do Django"
echo "===================================="
echo ""

# URL base da API
API_URL="https://controlpanel.aws.leds.dev.br"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para testar endpoint
check_endpoint() {
    local endpoint=$1
    local method=$2
    local description=$3
    
    echo -n "  $description... "
    
    if [ "$method" == "GET" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_URL$endpoint" 2>&1)
    else
        response=$(curl -s -o /dev/null -w "%{http_code}" -X $method "$API_URL$endpoint" 2>&1)
    fi
    
    if [ $? -eq 0 ]; then
        case $response in
            200|201)
                echo -e "${GREEN}✓ Existe${NC} (HTTP $response)"
                return 0
                ;;
            401|403)
                echo -e "${YELLOW}⚠ Existe mas precisa auth${NC} (HTTP $response)"
                return 0
                ;;
            404)
                echo -e "${RED}✗ Não existe${NC} (HTTP $response)"
                return 1
                ;;
            *)
                echo -e "${YELLOW}? Status $response${NC}"
                return 2
                ;;
        esac
    else
        echo -e "${RED}✗ Erro de conexão${NC}"
        return 2
    fi
}

# Verificar conectividade
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
echo "2. Verificando endpoints..."
echo ""

# Autenticação
echo -e "${BLUE}📝 Autenticação:${NC}"
check_endpoint "/api/auth/login/" "POST" "Login"
check_endpoint "/api/auth/logout/" "POST" "Logout"
check_endpoint "/api/auth/refresh/" "POST" "Refresh Token"
check_endpoint "/api/auth/me/" "GET" "User Info"

echo ""

# Editais
echo -e "${BLUE}📄 Editais:${NC}"
check_endpoint "/api/editals/" "GET" "Listar Editais"
check_endpoint "/api/editals/1/" "GET" "Detalhes Edital"

echo ""

# Métricas
echo -e "${BLUE}📊 Métricas:${NC}"
check_endpoint "/api/metrics/engagement/" "GET" "Engagement Metrics"
check_endpoint "/api/metrics/messages/" "GET" "Messages List"

echo ""

# Histórico
echo -e "${BLUE}📜 Histórico:${NC}"
check_endpoint "/api/history/sessions/" "GET" "Sessions List"
check_endpoint "/api/history/sessions/1/" "GET" "Session Detail"
check_endpoint "/api/history/sessions/search/" "GET" "Sessions Search"

echo ""
echo "===================================="
echo ""

# Tentar descobrir endpoints existentes
echo "3. Tentando descobrir outros endpoints..."
echo ""

# Testar variações comuns
echo -e "${BLUE}🔍 Testando variações:${NC}"
check_endpoint "/api/" "GET" "/api/"
check_endpoint "/api/v1/" "GET" "/api/v1/"
check_endpoint "/admin/" "GET" "/admin/"
check_endpoint "/api/edital/" "GET" "/api/edital/ (singular)"
check_endpoint "/api/editais/" "GET" "/api/editais/ (plural PT)"
check_endpoint "/api/mensagens/" "GET" "/api/mensagens/"
check_endpoint "/api/conversas/" "GET" "/api/conversas/"

echo ""
echo "===================================="
echo "✅ Verificação concluída!"
echo ""
echo "📝 Próximos passos:"
echo "1. Anote quais endpoints existem (marcados com ✓)"
echo "2. Abra ENDPOINT_MAPPING.md e preencha"
echo "3. Me envie a informação para eu adaptar o frontend"
echo ""
