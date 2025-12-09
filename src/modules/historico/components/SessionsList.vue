<template>
  <Card>
    <CardHeader>
      <CardTitle>Sessões de Conversa</CardTitle>
      <CardDescription>
        Selecione uma sessão para visualizar a conversa completa
      </CardDescription>
    </CardHeader>
    <CardContent>
      <!-- Search -->
      <div class="mb-4">
        <Input
          v-model="searchQuery"
          placeholder="Buscar por email ou ID de usuário..."
          @input="handleSearch"
        />
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="space-y-3">
        <div v-for="i in 5" :key="i" class="animate-pulse">
          <div class="h-16 bg-gray-200 rounded"></div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="sessions.length === 0" class="text-center py-12">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        </svg>
        <p class="mt-4 text-gray-600">Nenhuma sessão encontrada</p>
      </div>

      <!-- Sessions List -->
      <div v-else class="space-y-2 max-h-[600px] overflow-y-auto">
        <div
          v-for="session in paginatedSessions"
          :key="session.id"
          class="p-4 border rounded-lg cursor-pointer transition-all"
          :class="session.id === selectedSessionId 
            ? 'bg-primary/10 border-primary' 
            : 'hover:bg-gray-50 border-gray-200'"
          @click="selectSession(session.id)"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1 min-w-0">
              <div class="flex items-center space-x-2">
                <p class="text-sm font-medium text-gray-900 truncate">
                  {{ session.userEmail }}
                </p>
                <Badge size="sm">
                  {{ session.messageCount }} msgs
                </Badge>
              </div>
              <p class="text-xs text-gray-500 mt-1">
                ID: {{ session.userId }}
              </p>
              <p v-if="session.edital" class="text-xs text-gray-600 mt-1">
                {{ session.edital }}
              </p>
              <p class="text-xs text-gray-500 mt-1">
                {{ formatRelativeDate(session.startTime) }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex items-center justify-between mt-4 pt-4 border-t">
        <div class="text-sm text-gray-700">
          Página {{ currentPage }} de {{ totalPages }}
        </div>
        <div class="flex space-x-2">
          <Button
            variant="outline"
            size="sm"
            :disabled="currentPage === 1"
            @click="currentPage--"
          >
            Anterior
          </Button>
          <Button
            variant="outline"
            size="sm"
            :disabled="currentPage === totalPages"
            @click="currentPage++"
          >
            Próxima
          </Button>
        </div>
      </div>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { formatDistanceToNow } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Input from '@/common/components/ui/Input.vue'
import Badge from '@/common/components/ui/Badge.vue'
import Button from '@/common/components/ui/Button.vue'
import type { ConversationSession } from '@/common/types/api.types'

export interface SessionsListProps {
  sessions: ConversationSession[]
  selectedSessionId?: string
  isLoading: boolean
}

const props = withDefaults(defineProps<SessionsListProps>(), {
  isLoading: false,
})

const emit = defineEmits<{
  'session-select': [id: string]
  'search': [query: string]
}>()

const searchQuery = ref('')
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(props.sessions.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, props.sessions.length))

const paginatedSessions = computed(() => {
  return props.sessions.slice(startIndex.value, endIndex.value)
})

const selectSession = (id: string) => {
  emit('session-select', id)
}

const handleSearch = () => {
  currentPage.value = 1
  emit('search', searchQuery.value)
}

const formatRelativeDate = (timestamp: string): string => {
  try {
    return formatDistanceToNow(new Date(timestamp), { 
      addSuffix: true,
      locale: ptBR 
    })
  } catch {
    return timestamp
  }
}
</script>

<style scoped>
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>
