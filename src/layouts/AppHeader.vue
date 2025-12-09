<template>
  <header class="bg-white shadow-sm border-b">
    <div class="container mx-auto px-4 py-4">
      <div class="flex items-center justify-between">
        <!-- Logo and Title -->
        <div class="flex items-center space-x-4">
          <router-link to="/" class="flex items-center space-x-4 hover:opacity-80 transition-opacity">
            <Logo :width="120" :height="48" />
            <div>
              <h1 class="text-2xl font-bold text-gray-900">{{ title }}</h1>
              <p v-if="subtitle" class="text-sm text-gray-600">{{ subtitle }}</p>
            </div>
          </router-link>
        </div>

        <!-- Navigation -->
        <nav v-if="showNav" class="hidden md:flex items-center space-x-6">
          <router-link
            to="/"
            class="text-sm font-medium text-gray-700 hover:text-primary transition-colors"
            active-class="text-primary"
          >
            Início
          </router-link>
          <router-link
            to="/management"
            class="text-sm font-medium text-gray-700 hover:text-primary transition-colors"
            active-class="text-primary"
          >
            Gestão
          </router-link>
          <router-link
            to="/metrics"
            class="text-sm font-medium text-gray-700 hover:text-primary transition-colors"
            active-class="text-primary"
          >
            Métricas
          </router-link>
          <router-link
            to="/history"
            class="text-sm font-medium text-gray-700 hover:text-primary transition-colors"
            active-class="text-primary"
          >
            Histórico
          </router-link>
        </nav>

        <!-- User Menu -->
        <div class="flex items-center space-x-4">
          <span v-if="user" class="text-sm text-gray-600 hidden sm:inline">
            {{ user.name }}
          </span>
          <Button v-if="showLogout" variant="outline" size="sm" @click="handleLogout">
            Sair
          </Button>
        </div>

        <!-- Mobile Menu Button -->
        <button
          v-if="showNav"
          class="md:hidden p-2 rounded-md hover:bg-gray-100"
          @click="mobileMenuOpen = !mobileMenuOpen"
        >
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              v-if="!mobileMenuOpen"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 6h16M4 12h16M4 18h16"
            />
            <path
              v-else
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <!-- Mobile Menu -->
      <div v-if="showNav && mobileMenuOpen" class="md:hidden mt-4 pt-4 border-t">
        <nav class="flex flex-col space-y-2">
          <router-link
            to="/"
            class="px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md"
            @click="mobileMenuOpen = false"
          >
            Início
          </router-link>
          <router-link
            to="/management"
            class="px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md"
            @click="mobileMenuOpen = false"
          >
            Gestão
          </router-link>
          <router-link
            to="/metrics"
            class="px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md"
            @click="mobileMenuOpen = false"
          >
            Métricas
          </router-link>
          <router-link
            to="/history"
            class="px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md"
            @click="mobileMenuOpen = false"
          >
            Histórico
          </router-link>
        </nav>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import { useUiStore } from '@/common/store/ui'
import Button from '@/common/components/ui/Button.vue'
import Logo from '@/common/components/ui/Logo.vue'

export interface AppHeaderProps {
  title?: string
  subtitle?: string
  showNav?: boolean
  showLogout?: boolean
}

const props = withDefaults(defineProps<AppHeaderProps>(), {
  title: 'Gestão de Editais',
  subtitle: 'Sistema de Gerenciamento FAPES',
  showNav: true,
  showLogout: true,
})

const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUiStore()

const mobileMenuOpen = ref(false)

const user = computed(() => authStore.user)

const handleLogout = () => {
  authStore.logout()
  uiStore.showToast({
    type: 'success',
    message: 'Logout realizado com sucesso',
  })
  router.push('/login')
}
</script>
