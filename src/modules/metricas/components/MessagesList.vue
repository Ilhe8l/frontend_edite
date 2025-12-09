<template>
  <Card>
    <CardHeader>
      <div class="flex items-center justify-between">
        <div>
          <CardTitle>Mensagens</CardTitle>
          <CardDescription v-if="editalTitle">
            Filtrando por: {{ editalTitle }}
          </CardDescription>
          <CardDescription v-else>
            Todas as mensagens
          </CardDescription>
        </div>
        <Badge v-if="messages.length > 0">
          {{ messages.length }} mensagens
        </Badge>
      </div>
    </CardHeader>
    <CardContent>
      <!-- Loading State -->
      <div v-if="isLoading" class="space-y-3">
        <div v-for="i in 3" :key="i" class="animate-pulse">
          <div class="h-20 bg-gray-200 rounded"></div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="messages.length === 0" class="text-center py-12">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        </svg>
        <p class="mt-4 text-gray-600">Nenhuma mensagem encontrada</p>
      </div>

      <!-- Messages Table -->
      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Usuário
              </th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Pergunta
              </th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Resposta
              </th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Data
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="message in paginatedMessages"
              :key="message.id"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-4 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">
                  {{ message.userEmail }}
                </div>
                <div class="text-xs text-gray-500">
                  ID: {{ message.userId }}
                </div>
              </td>
              <td class="px-4 py-4">
                <div class="text-sm text-gray-900 max-w-xs truncate">
                  {{ message.question }}
                </div>
              </td>
              <td class="px-4 py-4">
                <div class="text-sm text-gray-900 max-w-xs truncate">
                  {{ message.botResponse }}
                </div>
              </td>
              <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(message.timestamp) }}
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex items-center justify-between px-4 py-3 border-t">
          <div class="text-sm text-gray-700">
            Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ messages.length }} mensagens
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
      </div>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Badge from '@/common/components/ui/Badge.vue'
import Button from '@/common/components/ui/Button.vue'
import type { Message } from '@/common/types/api.types'

export interface MessagesListProps {
  messages: Message[]
  editalTitle?: string
  isLoading: boolean
}

const props = withDefaults(defineProps<MessagesListProps>(), {
  isLoading: false,
})

const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(props.messages.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, props.messages.length))

const paginatedMessages = computed(() => {
  return props.messages.slice(startIndex.value, endIndex.value)
})

const formatDate = (timestamp: string): string => {
  try {
    return format(new Date(timestamp), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })
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
