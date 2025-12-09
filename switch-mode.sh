#!/bin/bash

# Script para alternar entre modo Mock e VPN

MODE=$1

if [ -z "$MODE" ]; then
    echo "❌ Uso: ./switch-mode.sh [mock|vpn]"
    echo ""
    echo "Exemplos:"
    echo "  ./switch-mode.sh mock   # Usar dados mock (offline)"
    echo "  ./switch-mode.sh vpn    # Conectar ao Django na VPN"
    exit 1
fi

case $MODE in
    mock)
        echo "🔄 Alternando para modo MOCK..."
        cp .env.development .env.local
        echo "✅ Modo MOCK ativado!"
        echo ""
        echo "📝 Configuração:"
        echo "   - VITE_USE_MOCK=true"
        echo "   - Dados fictícios serão usados"
        echo ""
        echo "🚀 Reinicie o servidor: npm run dev"
        ;;
    
    vpn)
        echo "🔄 Alternando para modo VPN..."
        cp .env.vpn .env.local
        echo "✅ Modo VPN ativado!"
        echo ""
        echo "📝 Configuração:"
        echo "   - VITE_USE_MOCK=false"
        echo "   - VITE_API_BASE_URL=https://controlpanel.aws.leds.dev.br/api"
        echo ""
        echo "⚠️  Certifique-se de:"
        echo "   1. Estar conectado à VPN"
        echo "   2. Django ter CORS configurado"
        echo "   3. Endpoints da API estarem criados"
        echo ""
        echo "🚀 Reinicie o servidor: npm run dev"
        ;;
    
    *)
        echo "❌ Modo inválido: $MODE"
        echo "Use: mock ou vpn"
        exit 1
        ;;
esac
