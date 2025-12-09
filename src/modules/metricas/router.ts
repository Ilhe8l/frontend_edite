import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/metrics',
    name: 'Metrics',
    component: () => import('./views/MetricsPage.vue'),
    meta: { requiresAuth: true },
  },
]

export default routes
