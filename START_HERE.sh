#!/bin/bash

echo "🚀 Sistema de Gestão de Editais - Vue.js"
echo "========================================"
echo ""
echo "📂 Entrando na pasta do projeto Vue.js..."
cd vue-edital-frontend

echo ""
echo "📦 Verificando dependências..."
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependências (isso pode levar alguns minutos)..."
    npm install
else
    echo "✅ Dependências já instaladas"
fi

echo ""
echo "⚙️  Configuração:"
echo "   ✅ Mock server ativado (dados simulados)"
echo "   ✅ Não precisa de VPN ou API real"
echo ""
echo "🎯 Iniciando servidor de desenvolvimento..."
echo ""
echo "📍 Acesse: http://localhost:5173"
echo ""
echo "🔐 Login de teste:"
echo "   Email: teste@example.com"
echo "   Senha: 123456"
echo ""
echo "========================================"
echo ""

npm run dev
