import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/history',
    name: 'History',
    component: () => import('./views/HistoryPage.vue'),
    meta: { requiresAuth: true },
  },
]

export default routes
