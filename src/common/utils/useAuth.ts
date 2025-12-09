import { computed } from 'vue'
import { useAuthStore } from '@/common/store/auth'

export function useAuth() {
  const authStore = useAuthStore()

  const user = computed(() => authStore.user)
  const isAuthenticated = computed(() => authStore.isAuthenticated)
  const isLoading = computed(() => authStore.isLoading)

  const login = async (email: string, password: string) => {
    return authStore.login({ email, password })
  }

  const logout = () => {
    authStore.logout()
  }

  const initializeAuth = () => {
    authStore.initializeFromStorage()
  }

  return {
    user,
    isAuthenticated,
    isLoading,
    login,
    logout,
    initializeAuth,
  }
}
