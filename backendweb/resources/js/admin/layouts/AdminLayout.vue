<template>
  <div class="d-flex admin-layout">
    <nav class="sidebar d-none d-md-flex flex-column flex-shrink-0 p-3">
      <router-link to="/dashboard" class="navbar-brand text-white mb-4 text-decoration-none">📍 TrackMe</router-link>
      <ul class="nav flex-column">
        <li class="nav-item">
          <router-link to="/dashboard" class="nav-link" active-class="active">儀表板</router-link>
        </li>
      </ul>
    </nav>

    <div class="flex-grow-1 d-flex flex-column min-vh-100">
      <nav class="navbar navbar-expand-md navbar-light bg-white border-bottom">
        <div class="container-fluid">
          <button class="navbar-toggler d-md-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
          </button>
          <div class="collapse navbar-collapse" id="navbarNav">
            <span class="navbar-text me-auto">
              <span
                class="badge me-2"
                :class="user?.role === 'super_admin' ? 'bg-danger' : 'bg-primary'"
              >
                {{ user?.role === 'super_admin' ? '超級管理者' : '店家管理者' }}
              </span>
              {{ user?.name }}
              <small v-if="user?.store" class="text-muted">({{ user.store.name }})</small>
            </span>
            <form method="POST" action="/admin/logout" class="d-inline">
              <input type="hidden" name="_token" :value="csrfToken" />
              <button type="submit" class="btn btn-outline-secondary btn-sm">登出</button>
            </form>
          </div>
        </div>
      </nav>

      <main class="p-3 p-md-4 flex-grow-1">
        <slot />
      </main>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminLayout',
  props: {
    user: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      csrfToken: '',
    };
  },
  mounted() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
  },
};
</script>

<style scoped>
.sidebar {
  min-height: 100vh;
  background: #1e3a5f;
  width: 220px;
}
.sidebar .nav-link {
  color: rgba(255, 255, 255, 0.85);
}
.sidebar .nav-link:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
}
.sidebar .nav-link.active {
  color: #fff;
  background: rgba(255, 255, 255, 0.2);
}
.navbar-brand {
  font-weight: 700;
}
</style>
