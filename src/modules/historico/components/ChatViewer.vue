<template>
  <Card>
    <CardHeader>
      <div class="flex items-center justify-between">
        <div>
          <CardTitle>Visualizador de Conversa</CardTitle>
          <CardDescription v-if="session">
            {{ session.userEmail }} • {{ formatDate(session.startTime) }}
          </CardDescription>
        </div>
        <Badge v-if="session" variant="secondary">
          {{ session.messageCount }} mensagens
        </Badge>
      </div>
    </CardHeader>
    <CardContent>
      <!-- Loading State -->
      <div v-if="isLoading" class="space-y-3">
        <div v-for="i in 4" :key="i" class="animate-pulse">
          <div :class="i % 2 === 0 ? 'ml-auto w-3/4' : 'w-3/4'">
            <div class="h-16 bg-gray-200 rounded-lg"></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="!session" class="text-center py-16">
        <svg class="mx-auto h-16 w-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        </svg>
        <p class="mt-4 text-gray-600">Selecione uma sessão para visualizar a conversa</p>
      </div>

      <!-- Chat Messages -->
      <div v-else ref="messagesContainer" class="space-y-4 max-h-[600px] overflow-y-auto p-4 bg-gray-50 rounded-lg">
        <div
          v-for="message in session.messages"
          :key="message.id"
          class="flex"
          :class="message.role === 'user' ? 'justify-end' : 'justify-start'"
        >
          <div
            class="max-w-[75%] rounded-lg px-4 py-3 shadow-sm"
            :class="messageClasses(message.role)"
          >
            <div class="flex items-center space-x-2 mb-1">
              <span class="text-xs font-semibold">
                {{ message.role === 'user' ? 'Usuário' : 'Bot' }}
              </span>
              <span class="text-xs opacity-75">
                {{ formatTime(message.timestamp) }}
              </span>
            </div>
            <p class="text-sm whitespace-pre-wrap">{{ message.content }}</p>
          </div>
        </div>
      </div>

      <!-- Session Info -->
      <div v-if="session" class="mt-4 pt-4 border-t">
        <div class="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p class="text-gray-600">Início da sessão</p>
            <p class="font-medium">{{ formatDate(session.startTime) }}</p>
          </div>
          <div>
            <p class="text-gray-600">Fim da sessão</p>
            <p class="font-medium">{{ formatDate(session.endTime) }}</p>
          </div>
          <div v-if="session.edital">
            <p class="text-gray-600">Edital</p>
            <p class="font-medium">{{ session.edital }}</p>
          </div>
          <div>
            <p class="text-gray-600">Duração</p>
            <p class="font-medium">{{ calculateDuration(session.startTime, session.endTime) }}</p>
          </div>
        </div>
      </div>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { ref, watch, nextTick } from 'vue'
import { format, differenceInMinutes } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Badge from '@/common/components/ui/Badge.vue'
import type { ConversationSession } from '@/common/types/api.types'

export interface ChatViewerProps {
  session: ConversationSession | null
  isLoading: boolean
}

const props = withDefaults(defineProps<ChatViewerProps>(), {
  isLoading: false,
})

const messagesContainer = ref<HTMLElement | null>(null)

const messageClasses = (role: 'user' | 'bot') => {
  if (role === 'user') {
    return 'bg-primary text-primary-foreground'
  }
  return 'bg-white border border-gray-200'
}

const formatDate = (timestamp: string): string => {
  try {
    return format(new Date(timestamp), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })
  } catch {
    return timestamp
  }
}

const formatTime = (timestamp: string): string => {
  try {
    return format(new Date(timestamp), 'HH:mm', { locale: ptBR })
  } catch {
    return timestamp
  }
}

const calculateDuration = (start: string, end: string): string => {
  try {
    const minutes = differenceInMinutes(new Date(end), new Date(start))
    if (minutes < 60) {
      return `${minutes} minutos`
    }
    const hours = Math.floor(minutes / 60)
    const remainingMinutes = minutes % 60
    return `${hours}h ${remainingMinutes}min`
  } catch {
    return 'N/A'
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

// Auto-scroll when session changes
watch(() => props.session, () => {
  if (props.session) {
    scrollToBottom()
  }
}, { immediate: true })
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
