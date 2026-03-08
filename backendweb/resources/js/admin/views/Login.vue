<template>
  <div class="login-wrapper">
    <div class="login-card">
      <div class="login-brand">
        <h1>📍 TrackMe 管理後台</h1>
        <p>追蹤定位系統 · 僅限管理者登入</p>
      </div>
      <div class="login-body">
        <div v-if="errors.length" class="alert alert-danger py-2 mb-3" role="alert">
          <small v-for="(err, i) in errors" :key="i">{{ err }}</small>
        </div>

        <form @submit.prevent="handleLogin">
          <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input
              v-model="form.email"
              type="email"
              class="form-control"
              :class="{ 'is-invalid': hasError('email') }"
              id="email"
              placeholder="admin@trackme.com"
              required
              autocomplete="email"
            />
          </div>
          <div class="mb-3">
            <label for="password" class="form-label">密碼</label>
            <input
              v-model="form.password"
              type="password"
              class="form-control"
              :class="{ 'is-invalid': hasError('password') }"
              id="password"
              required
              autocomplete="current-password"
            />
          </div>
          <div class="mb-3 form-check">
            <input v-model="form.remember" type="checkbox" class="form-check-input" id="remember" />
            <label class="form-check-label" for="remember">記住我</label>
          </div>
          <button type="submit" class="btn btn-primary btn-login w-100" :disabled="loading">
            {{ loading ? '登入中...' : '登入' }}
          </button>
        </form>

        <div class="mt-4 pt-3 border-top">
          <p class="text-muted small mb-0">支援角色：</p>
          <span class="badge bg-dark role-badge me-1">超級管理者</span>
          <span class="badge bg-secondary role-badge">店家管理者</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Login',
  data() {
    return {
      form: {
        email: '',
        password: '',
        remember: false,
      },
      errors: [],
      loading: false,
    };
  },
  methods: {
    hasError(field) {
      return this.errors.some((e) => e.toLowerCase().includes(field));
    },
    async handleLogin() {
      this.errors = [];
      this.loading = true;
      try {
        const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        const formData = new FormData();
        formData.append('_token', csrf || '');
        formData.append('email', this.form.email);
        formData.append('password', this.form.password);
        formData.append('remember', this.form.remember ? '1' : '0');

        const res = await fetch('/admin/login', {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-TOKEN': csrf || '',
          },
          credentials: 'same-origin',
          body: formData,
        });

        const data = await res.json().catch(() => ({}));

        if (res.ok) {
          this.$router.push('/dashboard');
          return;
        }

        if (res.status === 422 && data.errors) {
          this.errors = Object.values(data.errors).flat();
        } else {
          this.errors = [data.message || '登入失敗，請稍後再試'];
        }
      } catch (e) {
        this.errors = ['網路錯誤，請稍後再試'];
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
.login-wrapper {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}
.login-card {
  background: #fff;
  border-radius: 1rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  width: 100%;
  max-width: 420px;
}
.login-brand {
  background: linear-gradient(135deg, #1e3a5f 0%, #2d5a87 100%);
  color: #fff;
  padding: 2rem;
  text-align: center;
}
.login-brand h1 {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}
.login-brand p {
  font-size: 0.875rem;
  opacity: 0.9;
}
.login-body {
  padding: 2rem;
}
.role-badge {
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
}
.btn-login {
  font-weight: 600;
  padding: 0.6rem 1.5rem;
}
</style>
