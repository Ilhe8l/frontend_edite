<template>
  <div v-if="isAuthenticated">
    <slot />
  </div>
  <div v-else class="min-h-screen flex items-center justify-center">
    <Spinner class="h-8 w-8" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import Spinner from '@/common/components/ui/Spinner.vue'

const router = useRouter()
const authStore = useAuthStore()

const isAuthenticated = computed(() => authStore.isAuthenticated)

onMounted(() => {
  // Initialize auth from storage on mount
  authStore.initializeFromStorage()
  
  // If not authenticated after initialization, redirect to login
  if (!authStore.isAuthenticated) {
    router.push({ name: 'Login', query: { redirect: router.currentRoute.value.fullPath } })
  }
})
</script>
