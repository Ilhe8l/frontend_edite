<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <Button variant="ghost" size="sm" @click="router.push('/')">
              ← Voltar
            </Button>
            <h1 class="text-2xl font-bold text-gray-900">Métricas e Análises</h1>
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
    <main class="container mx-auto px-4 py-8">
      <div class="max-w-7xl mx-auto space-y-6">
        <!-- Info Alert -->
        <Alert>
          <p class="text-sm">
            <strong>Dica:</strong> Clique em uma barra do gráfico para filtrar as mensagens por edital específico.
          </p>
        </Alert>

        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card>
            <CardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Total de Mensagens</p>
                  <p class="text-3xl font-bold text-gray-900 mt-2">
                    {{ isLoading ? '...' : metrics?.total_messages || 0 }}
                  </p>
                </div>
                <div class="p-3 bg-blue-100 rounded-full">
                  <svg class="h-8 w-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Total de Usuários</p>
                  <p class="text-3xl font-bold text-gray-900 mt-2">
                    {{ isLoading ? '...' : metrics?.total_users || 0 }}
                  </p>
                </div>
                <div class="p-3 bg-green-100 rounded-full">
                  <svg class="h-8 w-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                  </svg>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Total de Editais</p>
                  <p class="text-3xl font-bold text-gray-900 mt-2">
                    {{ isLoading ? '...' : metrics?.total_editals || 0 }}
                  </p>
                </div>
                <div class="p-3 bg-purple-100 rounded-full">
                  <svg class="h-8 w-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <!-- Engagement Chart -->
        <EngagementChart
          v-if="metrics?.editals"
          :data="metrics.editals"
          @edital-click="handleEditalClick"
        />

        <!-- Filter Info -->
        <div v-if="selectedEditalId" class="flex items-center justify-between p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div class="flex items-center space-x-2">
            <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
            <span class="text-sm font-medium text-blue-900">
              Filtrando por: {{ selectedEditalTitle }}
            </span>
          </div>
          <Button variant="outline" size="sm" @click="clearFilter">
            Limpar Filtro
          </Button>
        </div>

        <!-- Messages List -->
        <MessagesList
          :messages="messages"
          :edital-title="selectedEditalTitle"
          :is-loading="isLoadingMessages"
        />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import { useUiStore } from '@/common/store/ui'
import { metricsService } from '@/services/metrics.service'
import Card from '@/common/components/ui/Card.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Button from '@/common/components/ui/Button.vue'
import Alert from '@/common/components/ui/Alert.vue'
import EngagementChart from '@/modules/metricas/components/EngagementChart.vue'
import MessagesList from '@/modules/metricas/components/MessagesList.vue'
import type { EngagementMetricsResponse, Message } from '@/common/types/api.types'

const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUiStore()

const metrics = ref<EngagementMetricsResponse | null>(null)
const messages = ref<Message[]>([])
const selectedEditalId = ref<string | null>(null)
const selectedEditalTitle = ref<string>('')
const isLoading = ref(false)
const isLoadingMessages = ref(false)

const loadMetrics = async () => {
  isLoading.value = true
  try {
    metrics.value = await metricsService.getEngagementMetrics()
  } catch (error) {
    console.error('Error loading metrics:', error)
    uiStore.showToast({
      type: 'error',
      message: 'Erro ao carregar métricas',
    })
  } finally {
    isLoading.value = false
  }
}

const loadMessages = async (editalId?: string) => {
  isLoadingMessages.value = true
  try {
    messages.value = await metricsService.getEditalMessages(editalId)
  } catch (error) {
    console.error('Error loading messages:', error)
    uiStore.showToast({
      type: 'error',
      message: 'Erro ao carregar mensagens',
    })
  } finally {
    isLoadingMessages.value = false
  }
}

const handleEditalClick = (editalId: string) => {
  selectedEditalId.value = editalId
  const edital = metrics.value?.editals.find(e => e.id === editalId)
  selectedEditalTitle.value = edital?.title || ''
  loadMessages(editalId)
}

const clearFilter = () => {
  selectedEditalId.value = null
  selectedEditalTitle.value = ''
  loadMessages()
}

const handleLogout = () => {
  authStore.logout()
  uiStore.showToast({
    type: 'success',
    message: 'Logout realizado com sucesso',
  })
  router.push('/login')
}

onMounted(() => {
  loadMetrics()
  loadMessages()
})
</script>
