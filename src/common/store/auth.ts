import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/common/api/auth.service'
import type { User, LoginCredentials } from '@/common/types/user.types'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null)
  const accessToken = ref<string | null>(null)
  const refreshToken = ref<string | null>(null)
  const isLoading = ref(false)

  // Getters
  const isAuthenticated = computed(() => !!user.value && !!accessToken.value)

  // Actions
  async function login(credentials: LoginCredentials) {
    isLoading.value = true
    try {
      const response = await authService.login(credentials)
      user.value = response.user
      accessToken.value = response.tokens.access
      refreshToken.value = response.tokens.refresh

      // Persist to localStorage
      localStorage.setItem('access_token', response.tokens.access)
      localStorage.setItem('refresh_token', response.tokens.refresh)
      localStorage.setItem('user', JSON.stringify(response.user))
    } finally {
      isLoading.value = false
    }
  }

  function logout() {
    user.value = null
    accessToken.value = null
    refreshToken.value = null
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('user')
  }

  function setAccessToken(token: string) {
    accessToken.value = token
    localStorage.setItem('access_token', token)
  }

  function initializeFromStorage() {
    const storedUser = localStorage.getItem('user')
    const storedAccessToken = localStorage.getItem('access_token')
    const storedRefreshToken = localStorage.getItem('refresh_token')

    if (storedUser && storedAccessToken) {
      user.value = JSON.parse(storedUser)
      accessToken.value = storedAccessToken
      refreshToken.value = storedRefreshToken
    }
  }

  return {
    user,
    accessToken,
    refreshToken,
    isLoading,
    isAuthenticated,
    login,
    logout,
    setAccessToken,
    initializeFromStorage,
  }
})
