<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader
      v-if="showHeader"
      :title="title"
      :subtitle="subtitle"
      :show-nav="showNav"
      :show-logout="showLogout"
    />

    <main class="container mx-auto px-4 py-8">
      <div :class="containerClasses">
        <!-- Breadcrumbs -->
        <nav v-if="breadcrumbs && breadcrumbs.length > 0" class="mb-6">
          <ol class="flex items-center space-x-2 text-sm">
            <li v-for="(crumb, index) in breadcrumbs" :key="index" class="flex items-center">
              <router-link
                v-if="crumb.to && index < breadcrumbs.length - 1"
                :to="crumb.to"
                class="text-gray-600 hover:text-primary transition-colors"
              >
                {{ crumb.label }}
              </router-link>
              <span v-else class="text-gray-900 font-medium">
                {{ crumb.label }}
              </span>
              <svg
                v-if="index < breadcrumbs.length - 1"
                class="h-4 w-4 mx-2 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </li>
          </ol>
        </nav>

        <!-- Page Title -->
        <div v-if="pageTitle" class="mb-6">
          <h1 class="text-3xl font-bold text-gray-900">{{ pageTitle }}</h1>
          <p v-if="pageDescription" class="mt-2 text-gray-600">{{ pageDescription }}</p>
        </div>

        <!-- Content Slot -->
        <slot />
      </div>
    </main>

    <!-- Footer (optional) -->
    <footer v-if="showFooter" class="bg-white border-t mt-auto">
      <div class="container mx-auto px-4 py-6">
        <p class="text-center text-sm text-gray-600">
          © {{ currentYear }} FAPES - Fundação de Amparo à Pesquisa e Inovação do Espírito Santo
        </p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import AppHeader from './AppHeader.vue'

export interface Breadcrumb {
  label: string
  to?: string
}

export interface PageContainerProps {
  title?: string
  subtitle?: string
  pageTitle?: string
  pageDescription?: string
  showHeader?: boolean
  showNav?: boolean
  showLogout?: boolean
  showFooter?: boolean
  maxWidth?: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | 'full'
  breadcrumbs?: Breadcrumb[]
}

const props = withDefaults(defineProps<PageContainerProps>(), {
  showHeader: true,
  showNav: true,
  showLogout: true,
  showFooter: false,
  maxWidth: '7xl',
})

const currentYear = new Date().getFullYear()

const containerClasses = computed(() => {
  const maxWidthClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-xl',
    '2xl': 'max-w-2xl',
    '7xl': 'max-w-7xl',
    full: 'max-w-full',
  }

  return `mx-auto ${maxWidthClasses[props.maxWidth as keyof typeof maxWidthClasses] || maxWidthClasses['7xl']}`
})
</script>
