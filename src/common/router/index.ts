import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '../store/auth'

// Import module routers
import autenticacaoRoutes from '@/modules/autenticacao/router'
import gestaoEditaisRoutes from '@/modules/gestao-editais/router'
import metricasRoutes from '@/modules/metricas/router'
import historicoRoutes from '@/modules/historico/router'

const routes: RouteRecordRaw[] = [
  ...autenticacaoRoutes,
  ...gestaoEditaisRoutes,
  ...metricasRoutes,
  ...historicoRoutes,
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Navigation guard
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const requiresAuth = to.meta.requiresAuth !== false

  if (requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (to.name === 'Login' && authStore.isAuthenticated) {
    next({ name: 'Home' })
  } else {
    next()
  }
})

export default router
