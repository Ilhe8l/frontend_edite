import { useUiStore } from '@/common/store/ui'

export function useToast() {
  const uiStore = useUiStore()

  const showSuccess = (message: string, duration?: number) => {
    uiStore.showToast({
      type: 'success',
      message,
      duration,
    })
  }

  const showError = (message: string, duration?: number) => {
    uiStore.showToast({
      type: 'error',
      message,
      duration,
    })
  }

  const showInfo = (message: string, duration?: number) => {
    uiStore.showToast({
      type: 'info',
      message,
      duration,
    })
  }

  const showWarning = (message: string, duration?: number) => {
    uiStore.showToast({
      type: 'warning',
      message,
      duration,
    })
  }

  return {
    showSuccess,
    showError,
    showInfo,
    showWarning,
  }
}
