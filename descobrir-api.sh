#!/bin/bash

echo "🔍 Descobrindo API do Django"
echo "============================="
echo ""

API_URL="https://controlpanel.aws.leds.dev.br"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "Testando caminhos comuns..."
echo ""

# Testar se tem API REST Framework
echo -e "${BLUE}1. Verificando Django REST Framework:${NC}"
response=$(curl -s "$API_URL/api/" 2>&1)
if echo "$response" | grep -q "API\|api\|rest"; then
    echo -e "${GREEN}✓${NC} /api/ existe!"
    echo "$response" | head -20
else
    echo -e "${YELLOW}⚠${NC} /api/ não encontrado"
fi

echo ""

# Testar admin
echo -e "${BLUE}2. Verificando Django Admin:${NC}"
response=$(curl -s "$API_URL/admin/" 2>&1)
if echo "$response" | grep -q "Django\|admin"; then
    echo -e "${GREEN}✓${NC} /admin/ existe (Django Admin)"
else
    echo -e "${YELLOW}⚠${NC} /admin/ não encontrado"
fi

echo ""

# Testar se tem documentação da API
echo -e "${BLUE}3. Procurando documentação da API:${NC}"

docs_paths=(
    "/api/docs/"
    "/api/swagger/"
    "/api/redoc/"
    "/docs/"
    "/swagger/"
    "/api-docs/"
    "/api/schema/"
)

for path in "${docs_paths[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL$path" 2>&1)
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✓${NC} $path (HTTP $response) - DOCUMENTAÇÃO ENCONTRADA!"
    fi
done

echo ""
echo "============================="
echo ""
echo "📋 O que fazer agora:"
echo ""
echo "1. Abra o navegador e acesse:"
echo "   https://controlpanel.aws.leds.dev.br/admin/"
echo ""
echo "2. Faça login no Django Admin"
echo ""
echo "3. Procure por:"
echo "   - Link 'API' no menu"
echo "   - Link 'Documentação'"
echo "   - Seção 'REST API'"
echo ""
echo "4. Ou me diga:"
echo "   - O Django tem Django REST Framework instalado?"
echo "   - Existe alguma API exposta?"
echo "   - Como você acessa os dados normalmente?"
echo ""
