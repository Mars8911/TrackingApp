import { createApp } from 'vue';
import { createRouter, createWebHistory } from 'vue-router';
import App from './App.vue';
import routes from './router';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import '../../css/admin.css';

const router = createRouter({
  history: createWebHistory('/admin'),
  routes,
});

// 路由守衛：未登入導向登入頁，已登入訪問登入頁則導向 dashboard
router.beforeEach(async (to, from, next) => {
  const isLoginPage = to.path === '/login';

  if (isLoginPage) {
    try {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) return next({ path: '/dashboard' });
    } catch {}
    return next();
  }

  if (to.meta.requiresAuth) {
    try {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (!res.ok) return next({ path: '/login', query: { redirect: to.fullPath } });
    } catch {
      return next({ path: '/login' });
    }
  }
  next();
});

createApp(App).use(router).mount('#admin-app');
