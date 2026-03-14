export default [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    redirect: '/dashboard',
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/members',
    name: 'Members',
    component: () => import('../views/MembersList.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/members/:id',
    name: 'MemberDetail',
    component: () => import('../views/MemberDetail.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/members/:id/location',
    name: 'MemberLocation',
    component: () => import('../views/MemberLocation.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/push-notifications',
    name: 'PushNotifications',
    component: () => import('../views/PushNotification.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard',
  },
];
