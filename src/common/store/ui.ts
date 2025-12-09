import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface Toast {
  id: string
  type: 'success' | 'error' | 'info' | 'warning'
  message: string
  duration?: number
}

export const useUiStore = defineStore('ui', () => {
  const toasts = ref<Toast[]>([])

  function showToast(toast: Omit<Toast, 'id'>) {
    const id = Date.now().toString()
    const newToast: Toast = { ...toast, id }
    toasts.value.push(newToast)

    const duration = toast.duration || 3000
    setTimeout(() => {
      removeToast(id)
    }, duration)
  }

  function removeToast(id: string) {
    toasts.value = toasts.value.filter((t) => t.id !== id)
  }

  return {
    toasts,
    showToast,
    removeToast,
  }
})
