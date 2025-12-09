import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('./views/LoginPage.vue'),
    meta: { requiresAuth: false },
  },
]

export default routes
