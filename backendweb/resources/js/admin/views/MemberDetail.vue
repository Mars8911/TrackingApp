<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><router-link to="/members">會員資訊</router-link></li>
          <li class="breadcrumb-item active">會員詳情</li>
        </ol>
      </nav>

      <div v-if="loading" class="text-center py-5">載入中...</div>

      <template v-else-if="member">
        <form @submit.prevent="handleSave">
          <!-- 會員等級與積分 -->
          <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white">
              <h5 class="mb-0">會員等級與積分</h5>
            </div>
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-4">
                  <label class="form-label">會員等級</label>
                  <select v-model="form.member_level" class="form-select">
                    <option value="一般">一般</option>
                    <option value="優質">優質</option>
                    <option value="VIP">VIP</option>
                  </select>
                </div>
                <div class="col-md-4">
                  <label class="form-label">積分</label>
                  <input v-model.number="form.points" type="number" class="form-control" min="0" />
                </div>
              </div>
              <div class="mt-3 small text-muted">
                繳款積分：提前還款+3、準時還款+1、延遲3日內-2、3日以上依欄位
              </div>
            </div>
          </div>

          <!-- 客戶個人資料 -->
          <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white">
              <h5 class="mb-0">客戶個人資料</h5>
            </div>
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">客戶姓名</label>
                  <input v-model="form.name" type="text" class="form-control" required />
                </div>
                <div class="col-md-6">
                  <label class="form-label">身分證字號</label>
                  <input v-model="form.id_number" type="text" class="form-control" />
                </div>
                <div class="col-md-6">
                  <label class="form-label">電話</label>
                  <input v-model="form.phone" type="text" class="form-control" />
                </div>
                <div class="col-md-6">
                  <label class="form-label">地址</label>
                  <input v-model="form.address" type="text" class="form-control" />
                </div>
                <div class="col-md-6">
                  <label class="form-label">緊急連絡人</label>
                  <input v-model="form.emergency_contact" type="text" class="form-control" />
                </div>
                <div class="col-md-6">
                  <label class="form-label">緊急連絡人電話</label>
                  <input v-model="form.emergency_phone" type="text" class="form-control" />
                </div>
              </div>
            </div>
          </div>

          <!-- 貸款案件（可編輯） -->
          <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
              <h5 class="mb-0">貸款案件</h5>
              <button type="button" class="btn btn-primary btn-sm" @click="openAddLoanModal">新增案件</button>
            </div>
            <div class="card-body">
              <div v-for="(loan, idx) in loanForms" :key="loan.id" class="loan-case-row border rounded p-3 mb-3">
                <div class="d-flex justify-content-between align-items-start mb-3">
                  <span class="text-muted small">案件 #{{ loan.id }}</span>
                  <button
                    type="button"
                    class="btn btn-danger btn-sm"
                    @click="handleDeleteLoan(idx)"
                  >
                    刪除此案件
                  </button>
                </div>

                <!-- 還款方式（選定後不可更改） -->
                <div class="row g-3 mb-3">
                  <div class="col-12">
                    <label class="form-label fw-semibold me-2">還款方式</label>
                    <span class="badge bg-secondary fs-6">{{ repaymentLabel(loan.repayment_type) }}</span>
                    <span class="text-muted small ms-2">（選定後不可更改）</span>
                  </div>
                </div>

                <!-- 擔保品與金額（共用） -->
                <div class="row g-3 mb-3">
                  <div class="col-md-3">
                    <label class="form-label small text-muted">擔保品下拉選單</label>
                    <select v-model="loan.collateral_type" class="form-select form-select-sm">
                      <option value="">請選擇</option>
                      <option value="汽車">汽車</option>
                      <option value="機車">機車</option>
                      <option value="房屋">房屋</option>
                      <option value="土地">土地</option>
                      <option value="其他">其他</option>
                    </select>
                  </div>
                  <div class="col-md-4">
                    <label class="form-label small text-muted">擔保品資訊</label>
                    <input
                      v-model="loan.collateral_info"
                      type="text"
                      class="form-control form-control-sm"
                      :placeholder="collateralPlaceholder(loan.collateral_type)"
                    />
                  </div>
                  <div class="col-md-2">
                    <label class="form-label small text-muted">借貸金額</label>
                    <input
                      :value="formatNumberInput(loan.loan_amount)"
                      type="text"
                      class="form-control form-control-sm"
                      inputmode="numeric"
                      @input="loan.loan_amount = parseNumberInput($event.target.value)"
                    />
                  </div>
                  <div class="col-md-2">
                    <label class="form-label small text-muted">尚餘</label>
                    <input
                      :value="formatNumberInput(loan.remaining_amount)"
                      type="text"
                      class="form-control form-control-sm"
                      inputmode="numeric"
                      @input="loan.remaining_amount = parseNumberInput($event.target.value)"
                    />
                  </div>
                </div>

                <!-- 還款相關欄位（依還款方式顯示不同格式） -->
                <div class="row g-3 mb-2">
                  <div class="col-md-2">
                    <label class="form-label small text-muted">利率 KEY 入</label>
                    <div class="input-group input-group-sm">
                      <input v-model.number="loan.interest_rate" type="number" class="form-control" min="0" step="0.1" />
                      <span class="input-group-text">%</span>
                    </div>
                  </div>
                  <div class="col-md-2">
                    <label class="form-label small text-muted">月還款金額 <span class="text-muted">(系統計算)</span></label>
                    <input
                      :value="'NT:' + formatNumberInput(loan.monthly_payment)"
                      type="text"
                      class="form-control form-control-sm bg-light"
                      readonly
                      placeholder="NT:0"
                    />
                  </div>
                  <div class="col-md-3">
                    <label class="form-label small text-muted">利息收取</label>
                    <select v-model="loan.interest_collection" class="form-select form-select-sm">
                      <option value="">請選擇</option>
                      <option value="前扣">前扣</option>
                      <option value="後收">後收</option>
                    </select>
                  </div>
                  <div class="col-md-2" v-if="loan.interest_collection === '前扣'">
                    <label class="form-label small text-muted">前扣月數</label>
                    <input
                      v-model.number="loan.interest_collection_months"
                      type="number"
                      class="form-control form-control-sm"
                      min="0"
                      placeholder="個月"
                    />
                  </div>
                  <div class="col-md-2">
                    <label class="form-label small text-muted">還款日</label>
                    <select v-model="loan.repayment_day" class="form-select form-select-sm">
                      <option value="">請選擇</option>
                      <option value="30天一期">30天一期</option>
                      <option value="每月">每月指定日</option>
                    </select>
                  </div>
                  <div class="col-md-1" v-if="loan.repayment_day === '每月'">
                    <label class="form-label small text-muted">日</label>
                    <input
                      v-model.number="loan.repayment_day_of_month"
                      type="number"
                      class="form-control form-control-sm"
                      min="1"
                      max="31"
                      placeholder="日"
                    />
                  </div>
                  <!-- 本利攤專屬：期數 -->
                  <div class="col-md-2" v-if="loan.repayment_type === 'amortization'">
                    <label class="form-label small text-muted">期數</label>
                    <input
                      v-model.number="loan.loan_periods"
                      type="number"
                      class="form-control form-control-sm"
                      min="0"
                      placeholder="個月"
                    />
                  </div>
                  <!-- 本利攤專屬：綁約 -->
                  <div class="col-md-2" v-if="loan.repayment_type === 'amortization'">
                    <label class="form-label small text-muted">綁約</label>
                    <input
                      v-model.number="loan.contract_months"
                      type="number"
                      class="form-control form-control-sm"
                      min="0"
                      placeholder="個月"
                    />
                  </div>
                </div>

                <!-- 繳款明細 -->
                <div class="mt-3 pt-3 border-top">
                  <div class="d-flex justify-content-between align-items-center mb-2">
                    <label class="form-label small fw-semibold mb-0">繳款明細</label>
                    <button type="button" class="btn btn-outline-primary btn-sm" @click="openAddRepaymentModal(loan)">
                      新增還款
                    </button>
                  </div>
                  <div class="table-responsive">
                    <table class="table table-sm table-bordered mb-0">
                      <thead class="table-light">
                        <tr>
                          <th>繳款日期</th>
                          <th>金額</th>
                          <th>狀態</th>
                          <th>備註</th>
                          <th width="80"></th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="r in getRepayments(loan.id)" :key="r.id">
                          <td>{{ formatDate(r.payment_date) }}</td>
                          <td>NT$ {{ formatNumber(r.amount) }}</td>
                          <td>
                            <span
                              class="badge"
                              :class="{
                                'bg-success': r.status === '準時',
                                'bg-info': r.status === '提前',
                                'bg-warning': r.status === '延遲',
                              }"
                            >
                              {{ r.status || '-' }}
                            </span>
                          </td>
                          <td class="small">{{ r.notes || '-' }}</td>
                          <td>
                            <button
                              type="button"
                              class="btn btn-outline-danger btn-sm py-0"
                              @click="handleDeleteRepayment(loan, r)"
                            >
                              刪除
                            </button>
                          </td>
                        </tr>
                        <tr v-if="!getRepayments(loan.id).length">
                          <td colspan="5" class="text-center text-muted py-3">尚無還款紀錄</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
              <div v-if="!loanForms.length" class="text-center text-muted py-4">尚無貸款案件</div>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary" :disabled="saving">{{ saving ? '儲存中...' : '儲存' }}</button>
            <router-link to="/members" class="btn btn-outline-secondary">返回列表</router-link>
          </div>
        </form>
      </template>
    </div>

    <!-- 新增還款 Modal -->
    <div v-if="showAddRepaymentModal" class="modal d-block" tabindex="-1" style="background: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">新增還款 - 案件 #{{ addRepaymentLoan?.id }}</h5>
            <button type="button" class="btn-close" @click="closeAddRepaymentModal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">繳款金額</label>
                <input
                  v-model.number="addRepaymentForm.amount"
                  type="number"
                  class="form-control"
                  min="0"
                  step="1"
                  placeholder="0"
                />
              </div>
              <div class="col-md-6">
                <label class="form-label">繳款日期</label>
                <input v-model="addRepaymentForm.payment_date" type="date" class="form-control" />
              </div>
              <div class="col-12">
                <label class="form-label">狀態</label>
                <select v-model="addRepaymentForm.status" class="form-select">
                  <option value="">請選擇</option>
                  <option value="準時">準時</option>
                  <option value="提前">提前</option>
                  <option value="延遲">延遲</option>
                </select>
              </div>
              <div class="col-12">
                <label class="form-label">備註</label>
                <input v-model="addRepaymentForm.notes" type="text" class="form-control" placeholder="選填" />
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-outline-secondary" @click="closeAddRepaymentModal">取消</button>
            <button type="button" class="btn btn-primary" :disabled="!addRepaymentForm.amount || !addRepaymentForm.payment_date" @click="confirmAddRepayment">
              確認新增
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新增案件：還款方式選擇 Modal -->
    <div v-if="showAddLoanModal" class="modal d-block" tabindex="-1" style="background: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">新增案件 - 選擇還款方式</h5>
            <button type="button" class="btn-close" @click="closeAddLoanModal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <p class="text-muted small mb-3">請選擇還款方式，選定後無法更改。</p>
            <div class="d-flex gap-3">
              <div class="form-check flex-grow-1 border rounded p-3">
                <input
                  v-model="addLoanRepaymentType"
                  type="radio"
                  value="interest_only"
                  id="add_interest_only"
                  class="form-check-input"
                />
                <label for="add_interest_only" class="form-check-label fw-semibold">A 純繳息</label>
              </div>
              <div class="form-check flex-grow-1 border rounded p-3">
                <input
                  v-model="addLoanRepaymentType"
                  type="radio"
                  value="amortization"
                  id="add_amortization"
                  class="form-check-input"
                />
                <label for="add_amortization" class="form-check-label fw-semibold">B 本利攤</label>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-outline-secondary" @click="closeAddLoanModal">取消</button>
            <button type="button" class="btn btn-primary" :disabled="!addLoanRepaymentType" @click="confirmAddLoan">
              確認新增
            </button>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import AdminLayout from '../layouts/AdminLayout.vue';

export default {
  name: 'MemberDetail',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      member: null,
      form: {},
      loanForms: [],
      loading: true,
      saving: false,
      showAddLoanModal: false,
      addLoanRepaymentType: null,
      showAddRepaymentModal: false,
      addRepaymentLoan: null,
      addRepaymentForm: { amount: 0, payment_date: '', status: '', notes: '' },
    };
  },
  mounted() {
    this.fetchUser();
    this.fetchMember();
  },
  methods: {
    formatNumber(n) {
      return Number(n || 0).toLocaleString('zh-TW');
    },
    formatNumberInput(n) {
      const num = Number(n);
      if (isNaN(num)) return '';
      return num.toLocaleString('zh-TW');
    },
    parseNumberInput(val) {
      const parsed = parseInt(String(val).replace(/,/g, ''), 10);
      return isNaN(parsed) ? 0 : parsed;
    },
    normalizeCollateralType(v) {
      const map = { 汽車機車: '汽車', 房屋土地: '房屋' };
      return map[v] || v || '';
    },
    collateralPlaceholder(type) {
      const map = {
        汽車: '車牌號',
        機車: '車牌號',
        房屋: '地址',
        土地: '地號',
        其他: '品名',
      };
      return map[type] ? `輸入${map[type]}` : '請輸入擔保品資訊';
    },
    openAddLoanModal() {
      this.addLoanRepaymentType = null;
      this.showAddLoanModal = true;
    },
    closeAddLoanModal() {
      this.showAddLoanModal = false;
      this.addLoanRepaymentType = null;
    },
    async confirmAddLoan() {
      if (!this.addLoanRepaymentType) return;
      try {
        const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        const res = await fetch(`/api/admin/members/${this.$route.params.id}/loans`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-TOKEN': csrf || '',
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify({ repayment_type: this.addLoanRepaymentType }),
        });
        if (res.ok) {
          const data = await res.json();
          const loan = data.loan;
          this.loanForms.push({
            id: loan.id,
            collateral_type: '',
            collateral_info: '',
            loan_amount: 0,
            remaining_amount: 0,
            interest_rate: 0,
            repayment_type: this.addLoanRepaymentType,
            monthly_payment: 0,
            interest_collection: '',
            interest_collection_months: null,
            repayment_day: '',
            repayment_day_of_month: null,
            loan_periods: null,
            contract_months: null,
            repayments: [],
          });
          if (this.member?.loans) this.member.loans.push(loan);
          this.closeAddLoanModal();
        } else {
          const err = await res.json().catch(() => ({}));
          alert(err.message || '新增失敗');
        }
      } catch (e) {
        alert('新增失敗');
      }
    },
    async handleDeleteLoan(idx) {
      if (!confirm('確定要刪除此貸款案件？')) return;
      const loan = this.loanForms[idx];
      try {
        const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        const res = await fetch(`/api/admin/loans/${loan.id}`, {
          method: 'DELETE',
          headers: {
            'Accept': 'application/json',
            'X-CSRF-TOKEN': csrf || '',
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
        });
        if (res.ok) {
          this.loanForms.splice(idx, 1);
          if (this.member?.loans) {
            this.member.loans = this.member.loans.filter((l) => l.id !== loan.id);
          }
          alert('已刪除');
        } else {
          alert('刪除失敗');
        }
      } catch (e) {
        alert('刪除失敗');
      }
    },
    repaymentLabel(v) {
      const map = { interest_only: '純繳息', amortization: '本利攤' };
      return map[v] || v || '-';
    },
    getRepayments(loanId) {
      const loan = this.loanForms.find((l) => l.id === loanId);
      return loan?.repayments || [];
    },
    formatDate(val) {
      if (!val) return '-';
      const d = new Date(val);
      if (isNaN(d.getTime())) return val;
      return d.toLocaleDateString('zh-TW', { year: 'numeric', month: '2-digit', day: '2-digit' });
    },
    openAddRepaymentModal(loan) {
      this.addRepaymentLoan = loan;
      this.addRepaymentForm = {
        amount: 0,
        payment_date: new Date().toISOString().slice(0, 10),
        status: '',
        notes: '',
      };
      this.showAddRepaymentModal = true;
    },
    closeAddRepaymentModal() {
      this.showAddRepaymentModal = false;
      this.addRepaymentLoan = null;
    },
    async confirmAddRepayment() {
      if (!this.addRepaymentLoan || !this.addRepaymentForm.amount || !this.addRepaymentForm.payment_date) return;
      try {
        const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        const res = await fetch(`/api/admin/loans/${this.addRepaymentLoan.id}/repayments`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-TOKEN': csrf || '',
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify(this.addRepaymentForm),
        });
        if (res.ok) {
          const data = await res.json();
          this.addRepaymentLoan.repayments = this.addRepaymentLoan.repayments || [];
          this.addRepaymentLoan.repayments.unshift(data.repayment);
          this.closeAddRepaymentModal();
        } else {
          const err = await res.json().catch(() => ({}));
          alert(err.message || '新增失敗');
        }
      } catch (e) {
        alert('新增失敗');
      }
    },
    async handleDeleteRepayment(loan, repayment) {
      if (!confirm('確定要刪除此還款紀錄？')) return;
      try {
        const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        const res = await fetch(`/api/admin/repayments/${repayment.id}`, {
          method: 'DELETE',
          headers: {
            'Accept': 'application/json',
            'X-CSRF-TOKEN': csrf || '',
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
        });
        if (res.ok) {
          loan.repayments = loan.repayments.filter((r) => r.id !== repayment.id);
        } else {
          alert('刪除失敗');
        }
      } catch (e) {
        alert('刪除失敗');
      }
    },
    parseRepaymentDay(val) {
      if (!val) return { type: '', day: null };
      if (val === '30天一期') return { type: '30天一期', day: null };
      if (String(val).startsWith('每月')) {
        const m = String(val).match(/每月(\d+)日?/);
        return { type: '每月', day: m ? parseInt(m[1], 10) : null };
      }
      return { type: val, day: null };
    },
    buildRepaymentDay(loan) {
      if (loan.repayment_day === '30天一期') return '30天一期';
      if (loan.repayment_day === '每月' && loan.repayment_day_of_month != null && loan.repayment_day_of_month > 0) {
        return `每月${loan.repayment_day_of_month}日`;
      }
      return loan.repayment_day || null;
    },
    parseInterestCollection(val) {
      if (!val) return { type: '', months: null };
      if (val === '後收') return { type: '後收', months: null };
      const m = String(val).match(/前扣(\d+)/);
      return m ? { type: '前扣', months: parseInt(m[1], 10) } : { type: val, months: null };
    },
    buildInterestCollection(loan) {
      if (loan.interest_collection === '前扣' && loan.interest_collection_months != null) {
        return `前扣${loan.interest_collection_months}個月`;
      }
      if (loan.interest_collection === '後收') return '後收';
      return loan.interest_collection || null;
    },
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchMember() {
      this.loading = true;
      try {
        const res = await fetch(`/api/admin/members/${this.$route.params.id}`, { credentials: 'same-origin' });
        if (res.ok) {
          const data = await res.json();
          this.member = data.member;
          this.form = {
            name: this.member.name,
            member_level: this.member.member_level || '一般',
            points: this.member.points ?? 0,
            id_number: this.member.id_number || '',
            phone: this.member.phone || '',
            address: this.member.address || '',
            emergency_contact: this.member.emergency_contact || '',
            emergency_phone: this.member.emergency_phone || '',
          };
          this.loanForms = (this.member.loans || []).map((l) => {
            const parsed = this.parseRepaymentDay(l.repayment_day);
            const interestParsed = this.parseInterestCollection(l.interest_collection);
            return {
              id: l.id,
              collateral_type: this.normalizeCollateralType(l.collateral_type),
              collateral_info: l.collateral_info || '',
              loan_amount: l.loan_amount,
              remaining_amount: l.remaining_amount,
              interest_rate: l.interest_rate,
              repayment_type: l.repayment_type || 'amortization',
              monthly_payment: l.monthly_payment,
              interest_collection: interestParsed.type,
              interest_collection_months: interestParsed.months,
              repayment_day: parsed.type,
              repayment_day_of_month: parsed.day,
              loan_periods: l.loan_periods,
              contract_months: l.contract_months,
              repayments: [...(l.repayments || [])],
            };
          });
        }
      } finally {
        this.loading = false;
      }
    },
    async handleSave() {
      this.saving = true;
      try {
        const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        const headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-TOKEN': csrf || '',
          'X-Requested-With': 'XMLHttpRequest',
        };

        const res = await fetch(`/api/admin/members/${this.$route.params.id}`, {
          method: 'PUT',
          headers,
          credentials: 'same-origin',
          body: JSON.stringify(this.form),
        });
        if (!res.ok) {
          alert('會員資料儲存失敗');
          return;
        }
        const data = await res.json();
        this.member = data.member;
        this.form = { ...this.form, ...data.member };

        for (const loan of this.loanForms) {
          const lRes = await fetch(`/api/admin/loans/${loan.id}`, {
            method: 'PUT',
            headers,
            credentials: 'same-origin',
            body: JSON.stringify({
              collateral_type: loan.collateral_type,
              collateral_info: loan.collateral_info,
              loan_amount: loan.loan_amount,
              remaining_amount: loan.remaining_amount,
              interest_rate: loan.interest_rate,
              monthly_payment: loan.monthly_payment,
              repayment_day: this.buildRepaymentDay(loan),
              interest_collection: this.buildInterestCollection(loan),
              loan_periods: loan.repayment_type === 'amortization' ? loan.loan_periods : null,
              contract_months: loan.repayment_type === 'amortization' ? loan.contract_months : null,
            }),
          });
          if (lRes.ok) {
            const lData = await lRes.json();
            const idx = this.member.loans?.findIndex((l) => l.id === loan.id);
            if (idx >= 0 && this.member.loans) this.member.loans[idx] = lData.loan;
          }
        }

        alert('儲存成功');
      } catch (e) {
        alert('儲存失敗');
      } finally {
        this.saving = false;
      }
    },
  },
};
</script>
