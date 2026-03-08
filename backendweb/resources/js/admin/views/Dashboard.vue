<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <h1 class="h4 mb-4">儀表板</h1>

      <div class="alert alert-info py-2 mb-4" role="alert">
        <template v-if="user?.role === 'super_admin'">
          <strong>超級管理者</strong>：可查看全系統資料。
        </template>
        <template v-else>
          <strong>店家管理者</strong>：僅可查看所屬店家資料。
        </template>
      </div>

      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card border-0 shadow-sm">
            <div class="card-body">
              <h6 class="text-muted mb-1">案件總數</h6>
              <h4 class="mb-0">{{ summary.total_cases || 0 }}</h4>
            </div>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card border-0 shadow-sm">
            <div class="card-body">
              <h6 class="text-muted mb-1">貸款總額</h6>
              <h4 class="mb-0">${{ formatNumber(summary.total_loan_amount || 0) }}</h4>
            </div>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card border-0 shadow-sm">
            <div class="card-body">
              <h6 class="text-muted mb-1">待還餘額</h6>
              <h4 class="mb-0">${{ formatNumber(summary.total_remaining || 0) }}</h4>
            </div>
          </div>
        </div>
      </div>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white">
          <h5 class="mb-0">貸款案件</h5>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>店家</th>
                  <th>貸款金額</th>
                  <th>待還餘額</th>
                  <th>利率</th>
                  <th>還款類型</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="loan in loans" :key="loan.id">
                  <td>{{ loan.id }}</td>
                  <td>{{ loan.store?.name || '-' }}</td>
                  <td>${{ formatNumber(loan.loan_amount) }}</td>
                  <td>${{ formatNumber(loan.remaining_amount) }}</td>
                  <td>{{ loan.interest_rate }}%</td>
                  <td>{{ loan.repayment_type || '-' }}</td>
                </tr>
                <tr v-if="!loans.length">
                  <td colspan="6" class="text-center text-muted py-4">尚無資料</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import AdminLayout from '../layouts/AdminLayout.vue';

export default {
  name: 'Dashboard',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      summary: {},
      loans: [],
      loading: true,
    };
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    formatNumber(n) {
      return Number(n).toLocaleString('zh-TW');
    },
    async fetchData() {
      this.loading = true;
      try {
        const [userRes, dashRes] = await Promise.all([
          fetch('/api/admin/user', { credentials: 'same-origin' }),
          fetch('/api/admin/dashboard', { credentials: 'same-origin' }),
        ]);

        if (userRes.ok) {
          this.user = await userRes.json();
        }
        if (dashRes.ok) {
          const data = await dashRes.json();
          this.summary = data.summary || {};
          this.loans = data.loans || [];
        }
      } catch (e) {
        console.error(e);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
