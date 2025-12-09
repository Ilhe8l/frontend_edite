#!/bin/bash

echo "🚀 Iniciando Sistema de Gestão de Editais - Modo Teste"
echo "=================================================="
echo ""

# Verificar se node está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js 18+ ou 20+"
    exit 1
fi

echo "✅ Node.js $(node --version) encontrado"

# Verificar se pnpm está instalado
if command -v pnpm &> /dev/null; then
    echo "✅ pnpm $(pnpm --version) encontrado"
    PKG_MANAGER="pnpm"
elif command -v npm &> /dev/null; then
    echo "✅ npm $(npm --version) encontrado"
    PKG_MANAGER="npm"
else
    echo "❌ Nenhum gerenciador de pacotes encontrado"
    exit 1
fi

echo ""
echo "📦 Verificando dependências..."

# Verificar se node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependências..."
    $PKG_MANAGER install
else
    echo "✅ Dependências já instaladas"
fi

echo ""
echo "⚙️  Configurando ambiente de teste..."

# Verificar se .env.development existe
if [ ! -f ".env.development" ]; then
    echo "📝 Criando .env.development..."
    cp .env.example .env.development
    # Garantir que mock está ativado
    sed -i 's/VITE_USE_MOCK=false/VITE_USE_MOCK=true/' .env.development 2>/dev/null || \
    sed -i '' 's/VITE_USE_MOCK=false/VITE_USE_MOCK=true/' .env.development 2>/dev/null
fi

echo "✅ Mock server ativado (VITE_USE_MOCK=true)"
echo ""
echo "🎯 Iniciando servidor de desenvolvimento..."
echo ""
echo "📍 O sistema estará disponível em: http://localhost:5173"
echo ""
echo "🔐 Credenciais de teste:"
echo "   Email: teste@example.com"
echo "   Senha: 123456"
echo ""
echo "📖 Veja TESTING.md para guia completo de testes"
echo ""
echo "=================================================="
echo ""

# Iniciar servidor
$PKG_MANAGER run dev
