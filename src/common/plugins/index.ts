import type { App } from 'vue'
import { createPinia } from 'pinia'
import router from '../router'

export function registerPlugins(app: App) {
  // Register Pinia store
  const pinia = createPinia()
  app.use(pinia)
  
  // Register Vue Router
  app.use(router)
}
