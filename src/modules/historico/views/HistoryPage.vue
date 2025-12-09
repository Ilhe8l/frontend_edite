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
            <h1 class="text-2xl font-bold text-gray-900">Histórico de Conversas</h1>
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
            <strong>Dica:</strong> Use a busca para filtrar sessões por email ou ID de usuário. Clique em uma sessão para visualizar a conversa completa.
          </p>
        </Alert>

        <!-- Clear Selection Button -->
        <div v-if="selectedSessionId" class="flex justify-end">
          <Button variant="outline" @click="clearSelection">
            Limpar Seleção
          </Button>
        </div>

        <!-- Grid Layout -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Sessions List -->
          <div>
            <SessionsList
              :sessions="sessions"
              :selected-session-id="selectedSessionId"
              :is-loading="isLoadingSessions"
              @session-select="handleSessionSelect"
              @search="handleSearch"
            />
          </div>

          <!-- Chat Viewer -->
          <div>
            <ChatViewer
              :session="selectedSession"
              :is-loading="isLoadingSession"
            />
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import { useUiStore } from '@/common/store/ui'
import { historyService } from '@/services/history.service'
import Button from '@/common/components/ui/Button.vue'
import Alert from '@/common/components/ui/Alert.vue'
import SessionsList from '@/modules/historico/components/SessionsList.vue'
import ChatViewer from '@/modules/historico/components/ChatViewer.vue'
import type { ConversationSession } from '@/common/types/api.types'

const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUiStore()

const sessions = ref<ConversationSession[]>([])
const selectedSession = ref<ConversationSession | null>(null)
const selectedSessionId = ref<string | null>(null)
const isLoadingSessions = ref(false)
const isLoadingSession = ref(false)
const searchQuery = ref('')

const loadSessions = async () => {
  isLoadingSessions.value = true
  try {
    sessions.value = await historyService.getSessions()
  } catch (error) {
    console.error('Error loading sessions:', error)
    uiStore.showToast({
      type: 'error',
      message: 'Erro ao carregar sessões',
    })
  } finally {
    isLoadingSessions.value = false
  }
}

const loadSessionDetail = async (sessionId: string) => {
  isLoadingSession.value = true
  try {
    selectedSession.value = await historyService.getSessionDetail(sessionId)
  } catch (error) {
    console.error('Error loading session detail:', error)
    uiStore.showToast({
      type: 'error',
      message: 'Erro ao carregar detalhes da sessão',
    })
  } finally {
    isLoadingSession.value = false
  }
}

const handleSessionSelect = (sessionId: string) => {
  selectedSessionId.value = sessionId
  loadSessionDetail(sessionId)
}

const handleSearch = async (query: string) => {
  searchQuery.value = query
  
  if (!query.trim()) {
    loadSessions()
    return
  }

  isLoadingSessions.value = true
  try {
    // Try to parse as email or userId
    const isEmail = query.includes('@')
    if (isEmail) {
      sessions.value = await historyService.searchSessions(query)
    } else {
      sessions.value = await historyService.searchSessions(undefined, query)
    }
  } catch (error) {
    console.error('Error searching sessions:', error)
    uiStore.showToast({
      type: 'error',
      message: 'Erro ao buscar sessões',
    })
  } finally {
    isLoadingSessions.value = false
  }
}

const clearSelection = () => {
  selectedSessionId.value = null
  selectedSession.value = null
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
  loadSessions()
})
</script>
