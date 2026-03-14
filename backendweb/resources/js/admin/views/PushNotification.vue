<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <h1 class="h4 mb-4">訊息推播管理</h1>

      <div class="row">
        <div class="col-lg-8">
          <div class="card border-0 shadow-sm">
            <div class="card-header bg-white">
              <h5 class="mb-0">發送推播訊息</h5>
            </div>
            <div class="card-body">
              <form @submit.prevent="sendPush">
                <div class="mb-3">
                  <label class="form-label">發送對象</label>
                  <div class="d-flex gap-3">
                    <div class="form-check">
                      <input
                        v-model="targetType"
                        type="radio"
                        class="form-check-input"
                        id="targetAll"
                        value="all"
                      />
                      <label class="form-check-label" for="targetAll">群體發送（全部會員）</label>
                    </div>
                    <div class="form-check">
                      <input
                        v-model="targetType"
                        type="radio"
                        class="form-check-input"
                        id="targetSingle"
                        value="single"
                      />
                      <label class="form-check-label" for="targetSingle">指定會員</label>
                    </div>
                  </div>
                </div>

                <div v-if="targetType === 'single'" class="mb-3">
                  <label class="form-label">選擇會員</label>
                  <select v-model="selectedUserId" class="form-select" required>
                    <option value="">請選擇會員</option>
                    <option v-for="m in members" :key="m.id" :value="m.id">
                      {{ m.name }} ({{ m.email }})
                    </option>
                  </select>
                </div>

                <div class="mb-3">
                  <label class="form-label">標題 <span class="text-danger">*</span></label>
                  <input
                    v-model="form.title"
                    type="text"
                    class="form-control"
                    placeholder="例：繳款提醒"
                    maxlength="100"
                    required
                  />
                  <small class="text-muted">{{ form.title.length }}/100</small>
                </div>

                <div class="mb-3">
                  <label class="form-label">內容 <span class="text-danger">*</span></label>
                  <textarea
                    v-model="form.body"
                    class="form-control"
                    rows="4"
                    placeholder="輸入推播訊息內容..."
                    maxlength="500"
                    required
                  ></textarea>
                  <small class="text-muted">{{ form.body.length }}/500</small>
                </div>

                <div class="d-flex gap-2">
                  <button type="submit" class="btn btn-primary" :disabled="sending">
                    {{ sending ? '發送中...' : '發送推播' }}
                  </button>
                  <button type="button" class="btn btn-outline-secondary" @click="resetForm">
                    清除
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <div class="col-lg-4">
          <div class="card border-0 shadow-sm">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
              <h5 class="mb-0">發送對象預覽</h5>
              <span class="badge bg-primary">{{ targetCount }} 人</span>
            </div>
            <div class="card-body">
              <p v-if="targetType === 'all'" class="text-muted mb-0">
                將發送給目前店家下所有 {{ members.length }} 位會員
              </p>
              <div v-else-if="targetType === 'single' && selectedUser">
                <p class="mb-1 fw-medium">{{ selectedUser.name }}</p>
                <p class="text-muted small mb-0">{{ selectedUser.email }}</p>
              </div>
              <p v-else class="text-muted mb-0">請選擇發送對象</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import AdminLayout from '../layouts/AdminLayout.vue';

export default {
  name: 'PushNotification',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      members: [],
      targetType: 'all',
      selectedUserId: '',
      form: {
        title: '',
        body: '',
      },
      sending: false,
    };
  },
  computed: {
    targetCount() {
      if (this.targetType === 'all') return this.members.length;
      return this.targetType === 'single' && this.selectedUserId ? 1 : 0;
    },
    selectedUser() {
      if (!this.selectedUserId) return null;
      return this.members.find((m) => m.id === parseInt(this.selectedUserId, 10));
    },
  },
  mounted() {
    this.fetchUser();
    this.fetchMembers();
  },
  methods: {
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchMembers() {
      const res = await fetch('/api/admin/members', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.members = data.members || [];
      }
    },
    async sendPush() {
      if (this.targetType === 'single' && !this.selectedUserId) {
        alert('請選擇要發送的會員');
        return;
      }
      this.sending = true;
      try {
        const payload = {
          title: this.form.title.trim(),
          body: this.form.body.trim(),
          target_type: this.targetType,
          user_id: this.targetType === 'single' ? parseInt(this.selectedUserId, 10) : null,
        };
        const res = await fetch('/api/admin/push-notifications/send', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
            Accept: 'application/json',
          },
          credentials: 'same-origin',
          body: JSON.stringify(payload),
        });
        const data = await res.json();
        if (res.ok) {
          alert(data.message || '推播已發送');
          this.resetForm();
        } else {
          alert(data.message || '發送失敗，請稍後再試');
        }
      } catch (e) {
        alert('發送失敗，請稍後再試');
      } finally {
        this.sending = false;
      }
    },
    resetForm() {
      this.form.title = '';
      this.form.body = '';
    },
  },
};
</script>
