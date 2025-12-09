import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Home',
    component: () => import('./views/HomePage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/management',
    name: 'Management',
    component: () => import('./views/ManagementPage.vue'),
    meta: { requiresAuth: true },
  },
]

export default routes
