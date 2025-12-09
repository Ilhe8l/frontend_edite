import { ref } from 'vue'
import { useErrorHandler } from './useErrorHandler'

export function useApi<T = any>() {
  const data = ref<T | null>(null)
  const error = ref<Error | null>(null)
  const isLoading = ref(false)

  const { handleApiError } = useErrorHandler()

  const execute = async (
    apiCall: () => Promise<T>,
    options?: {
      onSuccess?: (data: T) => void
      onError?: (error: unknown) => void
      showErrorToast?: boolean
      errorMessage?: string
    }
  ) => {
    isLoading.value = true
    error.value = null

    try {
      const result = await apiCall()
      data.value = result

      if (options?.onSuccess) {
        options.onSuccess(result)
      }

      return result
    } catch (err) {
      error.value = err as Error

      if (options?.showErrorToast !== false) {
        handleApiError(err, options?.errorMessage)
      }

      if (options?.onError) {
        options.onError(err)
      }

      throw err
    } finally {
      isLoading.value = false
    }
  }

  const reset = () => {
    data.value = null
    error.value = null
    isLoading.value = false
  }

  return {
    data,
    error,
    isLoading,
    execute,
    reset,
  }
}
