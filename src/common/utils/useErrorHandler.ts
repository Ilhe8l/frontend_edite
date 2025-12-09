import { AxiosError } from 'axios'
import { useToast } from './useToast'

export function useErrorHandler() {
  const { showError } = useToast()

  const handleApiError = (error: unknown, customMessage?: string) => {
    console.error('API Error:', error)

    if (error instanceof AxiosError) {
      const status = error.response?.status
      const message = error.response?.data?.message || error.message

      switch (status) {
        case 400:
          showError(customMessage || `Erro de validação: ${message}`)
          break
        case 401:
          // Handled by axios interceptor
          break
        case 403:
          showError(customMessage || 'Você não tem permissão para esta ação')
          break
        case 404:
          showError(customMessage || 'Recurso não encontrado')
          break
        case 500:
        case 502:
        case 503:
          showError(customMessage || 'Erro no servidor. Tente novamente em alguns instantes.')
          break
        default:
          showError(customMessage || 'Erro inesperado. Tente novamente.')
      }

      return {
        status,
        message,
        isNetworkError: !error.response,
      }
    }

    showError(customMessage || 'Erro inesperado')
    return {
      status: null,
      message: 'Unknown error',
      isNetworkError: false,
    }
  }

  const handleNetworkError = () => {
    showError('Erro de conexão. Verifique sua internet e tente novamente.')
  }

  const handleValidationError = (errors: Record<string, string>) => {
    const firstError = Object.values(errors)[0]
    if (firstError) {
      showError(firstError)
    }
  }

  return {
    handleApiError,
    handleNetworkError,
    handleValidationError,
  }
}
