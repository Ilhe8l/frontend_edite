<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <Logo :width="120" :height="48" />
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Gestão de Editais</h1>
              <p class="text-sm text-gray-600">Sistema de Gerenciamento FAPES</p>
            </div>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600">{{ authStore.user?.name }}</span>
            <Button variant="outline" size="sm" @click="handleLogout">
              Sair
            </Button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-12">
      <div class="max-w-6xl mx-auto">
        <div class="mb-8">
          <h2 class="text-3xl font-bold text-gray-900 mb-2">
            Bem-vindo ao Sistema de Gestão de Editais
          </h2>
          <p class="text-lg text-gray-600">
            Escolha uma das opções abaixo para começar
          </p>
        </div>

        <!-- Feature Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- Management Card -->
          <Card :hover="true" class="cursor-pointer" @click="navigateTo('/management')">
            <CardContent class="p-6">
              <div class="flex flex-col items-center text-center space-y-4">
                <div class="p-4 bg-blue-100 rounded-full">
                  <FileText class="h-8 w-8 text-blue-600" />
                </div>
                <div>
                  <h3 class="text-xl font-semibold text-gray-900 mb-2">
                    Gestão de Editais
                  </h3>
                  <p class="text-gray-600">
                    Crie e gerencie editais, faça upload de documentos e configure metadados
                  </p>
                </div>
                <Button variant="outline" class="w-full">
                  Acessar
                </Button>
              </div>
            </CardContent>
          </Card>

          <!-- Metrics Card -->
          <Card :hover="true" class="cursor-pointer" @click="navigateTo('/metrics')">
            <CardContent class="p-6">
              <div class="flex flex-col items-center text-center space-y-4">
                <div class="p-4 bg-green-100 rounded-full">
                  <BarChart3 class="h-8 w-8 text-green-600" />
                </div>
                <div>
                  <h3 class="text-xl font-semibold text-gray-900 mb-2">
                    Métricas e Análises
                  </h3>
                  <p class="text-gray-600">
                    Visualize estatísticas de engajamento e mensagens por edital
                  </p>
                </div>
                <Button variant="outline" class="w-full">
                  Acessar
                </Button>
              </div>
            </CardContent>
          </Card>

          <!-- History Card -->
          <Card :hover="true" class="cursor-pointer" @click="navigateTo('/history')">
            <CardContent class="p-6">
              <div class="flex flex-col items-center text-center space-y-4">
                <div class="p-4 bg-purple-100 rounded-full">
                  <MessageSquare class="h-8 w-8 text-purple-600" />
                </div>
                <div>
                  <h3 class="text-xl font-semibold text-gray-900 mb-2">
                    Histórico de Conversas
                  </h3>
                  <p class="text-gray-600">
                    Acesse o histórico completo de conversas entre usuários e chatbot
                  </p>
                </div>
                <Button variant="outline" class="w-full">
                  Acessar
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        <!-- Info Alert -->
        <div class="mt-8">
          <Alert>
            <p class="text-sm">
              <strong>Dica:</strong> Use a navegação acima para acessar rapidamente as diferentes seções do sistema.
            </p>
          </Alert>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import { useUiStore } from '@/common/store/ui'
import Card from '@/common/components/ui/Card.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Button from '@/common/components/ui/Button.vue'
import Alert from '@/common/components/ui/Alert.vue'
import Logo from '@/common/components/ui/Logo.vue'
import { FileText, BarChart3, MessageSquare } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUiStore()

const navigateTo = (path: string) => {
  router.push(path)
}

const handleLogout = () => {
  authStore.logout()
  uiStore.showToast({
    type: 'success',
    message: 'Logout realizado com sucesso',
  })
  router.push('/login')
}
</script>
