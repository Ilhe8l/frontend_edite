#!/bin/bash

echo "🔧 Atualizando imports para nova estrutura..."
echo ""

# Função para substituir imports
fix_imports() {
    local file=$1
    
    # Stores
    sed -i "s|@/stores/auth.store|@/common/store/auth|g" "$file"
    sed -i "s|@/stores/ui.store|@/common/store/ui|g" "$file"
    sed -i "s|@/stores/edital.store|@/modules/gestao-editais/store/edital|g" "$file"
    
    # Services
    sed -i "s|@/services/api-client|@/common/api/client|g" "$file"
    sed -i "s|@/services/auth.service|@/common/api/auth.service|g" "$file"
    sed -i "s|@/services/mock.service|@/common/api/mock.service|g" "$file"
    sed -i "s|@/services/edital.service|@/modules/gestao-editais/services/edital.service|g" "$file"
    
    # Fix relative imports
    sed -i "s|from './api-client'|from './client'|g" "$file"
    sed -i "s|from \"./api-client\"|from \"./client\"|g" "$file"
    
    # Types
    sed -i "s|@/types/api.types|@/common/types/api.types|g" "$file"
    sed -i "s|@/types/user.types|@/common/types/user.types|g" "$file"
    sed -i "s|@/types/edital.types|@/common/types/edital.types|g" "$file"
    
    # Composables -> Utils
    sed -i "s|@/composables/useApi|@/common/utils/useApi|g" "$file"
    sed -i "s|@/composables/useAuth|@/common/utils/useAuth|g" "$file"
    sed -i "s|@/composables/useErrorHandler|@/common/utils/useErrorHandler|g" "$file"
    sed -i "s|@/composables/useToast|@/common/utils/useToast|g" "$file"
    
    # Components
    sed -i "s|@/components/ui/|@/common/components/ui/|g" "$file"
    sed -i "s|@/components/layout/|@/layouts/|g" "$file"
    sed -i "s|@/components/management/|@/modules/gestao-editais/components/|g" "$file"
    sed -i "s|@/components/metrics/|@/modules/metricas/components/|g" "$file"
    sed -i "s|@/components/history/|@/modules/historico/components/|g" "$file"
    
    # Views
    sed -i "s|@/views/LoginPage|@/modules/autenticacao/views/LoginPage|g" "$file"
    sed -i "s|@/views/HomePage|@/modules/gestao-editais/views/HomePage|g" "$file"
    sed -i "s|@/views/ManagementPage|@/modules/gestao-editais/views/ManagementPage|g" "$file"
    sed -i "s|@/views/MetricsPage|@/modules/metricas/views/MetricsPage|g" "$file"
    sed -i "s|@/views/HistoryPage|@/modules/historico/views/HistoryPage|g" "$file"
}

# Encontrar todos os arquivos .vue e .ts
echo "Procurando arquivos..."
files=$(find src -type f \( -name "*.vue" -o -name "*.ts" \))

count=0
for file in $files; do
    fix_imports "$file"
    count=$((count + 1))
    echo "  ✓ $file"
done

echo ""
echo "✅ $count arquivos atualizados!"
echo ""
echo "🚀 Próximo passo: npm run dev"
