<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><router-link to="/members">會員資訊</router-link></li>
          <li class="breadcrumb-item"><router-link :to="`/members/${memberId}`">會員詳情</router-link></li>
          <li class="breadcrumb-item active">位置</li>
        </ol>
      </nav>

      <div class="card border-0 shadow-sm">
        <div class="card-body text-center py-5">
          <p class="text-muted mb-0">即時定位地圖（開發中）</p>
          <p class="small text-muted mt-2">會員 ID: {{ memberId }}</p>
          <router-link :to="`/members/${memberId}`" class="btn btn-outline-primary mt-3">返回會員詳情</router-link>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import AdminLayout from '../layouts/AdminLayout.vue';

export default {
  name: 'MemberLocation',
  components: { AdminLayout },
  data() {
    return {
      user: null,
    };
  },
  computed: {
    memberId() {
      return this.$route.params.id;
    },
  },
  mounted() {
    fetch('/api/admin/user', { credentials: 'same-origin' })
      .then((r) => r.ok && r.json())
      .then((u) => { this.user = u; });
  },
};
</script>
