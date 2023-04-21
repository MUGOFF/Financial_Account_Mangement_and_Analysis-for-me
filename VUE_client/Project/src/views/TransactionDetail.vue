<template>
  <div class="container text-start">
    <div id="delete-button" class="text-end">x 거래내역 삭제</div>
    <div class="m-2">
      <label for="time" class="form-label">시간</label>
      <input
        type="datetime-local"
        class="form-control"
        id="time"
        v-model="transaction.transaction_time"
        @change="component_change()"
      />
    </div>
    <div class="m-2">
      <label for="bank" class="form-label">은행</label>
      <select
        id="bank"
        class="form-select"
        v-model="transaction.transaction_from"
        @change="component_change()"
        required
      >
        <option
          v-for="account in account_table"
          :key="account"
          :value="account.accountnumber"
        >
          {{ account.nickname }}
        </option>
      </select>
    </div>
    <div class="m-2">
      <label for="card" class="form-label">카드</label>
      <select
        id="card"
        class="form-select"
        v-model="transaction.transaction_from_card"
        @change="component_change()"
      >
        <option :value="null" selected>----------</option>
        <option v-for="card in card_table" :key="card" :value="card.cardnumber">
          {{ card.nickname }}
        </option>
      </select>
    </div>
    <div class="m-2">
      <label for="to-name" class="form-label">거래내역</label>
      <div class="input-group">
        <input
          type="text"
          class="form-control"
          id="to-name"
          list="company-names"
          v-model="transaction.transaction_to_name"
          @change="component_change()"
        />
        <datalist id="company-names">
          <option
            v-for="(name, index) in company_table"
            :key="index"
            :value="name.company_accountname"
          ></option>
        </datalist>
        <button class="btn btn-secondary" v-if="!exist_history_name">
          등록
        </button>
        <span class="input-group-text">내역 별칭</span>
        <input
          type="text"
          class="form-control"
          id="to-nickname"
          v-model="to_company.company_commonname"
          @change="history_change()"
        />
        <button class="btn btn-primary" v-if="history_changed">수정</button>
      </div>
    </div>
    <div class="m-2">
      <label for="category" class="form-label">항목</label>
      <div class="input-group">
        <input
          type="text"
          class="form-control"
          id="category"
          v-model="transaction.main_category"
          @change="component_change()"
        />
        <span class="input-group-text">고정 항목</span>
        <input
          type="text"
          class="form-control"
          id="to-nickname"
          v-model="to_company.category_hook"
          @change="component_change()"
        />
      </div>
    </div>
    <div class="m-2">
      <label for="hashtags" class="form-label">해쉬태그</label>
      <input
        type="text"
        class="form-control"
        id="hashtags"
        v-model="transaction.sub_category"
        @change="component_change()"
      />
    </div>
    <div class="m-2">
      <label for="deposit" class="form-label">입금금액</label>
      <input
        type="number"
        class="form-control"
        id="deposit"
        v-model="transaction.deposit_amount"
        @change="component_change()"
      />
    </div>
    <div class="m-2">
      <label for="withdrawal" class="form-label"> 출금금액</label>
      <input
        type="number"
        class="form-control"
        id="withdrawal"
        v-model="transaction.withdrawal_amount"
        @change="component_change()"
      />
    </div>
    <div class="m-2">
      <label for="description" class="form-label">비고</label>
      <textarea
        type="text"
        class="form-control"
        id="description"
        v-model="transaction.description"
        @change="component_change()"
      />
    </div>
    <div class="text-center m-3">
      <button class="btn btn-primary mx-2 btn-lg" @click="confirm_changes()">
        <span v-if="changed">수정</span>
        <span v-else>확인</span>
      </button>
      <button class="btn btn-secondary mx-2 btn-lg" @click="cancel_changes()">
        취소
      </button>
    </div>
  </div>
</template>
<script>
import axios from "axios";

export default {
  data() {
    return {
      changed: false,
      history_changed: false,
      transaction: {},
      to_company: {},
      account_table: {},
      card_table: {},
      company_table: {},
    };
  },
  computed: {
    exist_history_name() {
      const company_lsit = Object.values(this.company_table).map(
        (object) => object.company_accountname
      );
      console.log(company_lsit);
      console.log(this.transaction.transaction_to_name);
      console.log(company_lsit.includes(this.transaction.transaction_to_name));
      return company_lsit.includes(this.transaction.transaction_to_name);
    },
  },
  mounted() {
    this.get_table();
    this.import_transaction_data();
  },
  methods: {
    get_table() {
      axios
        .get("api/v1/account_management/bank_account/")
        .then((response) => {
          this.account_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      axios
        .get("api/v1/account_management/card_account/")
        .then((response) => {
          this.card_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      axios
        .get("api/v1/account_record/Company_nickname/")
        .then((response) => {
          this.company_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
    },
    async import_transaction_data() {
      this.$store.commit("setIsLoading", true);
      await axios
        .get(
          "api/v1/account_record/Transaction_All/" +
            this.$route.params.transactionId +
            "/"
        )
        .then((response) => {
          this.transaction = response.data;
          axios
            .get(
              "api/v1/account_record/Company_nickname/" +
                this.transaction.transaction_to_name +
                "/"
            )
            .then((response) => {
              this.to_company = response.data;
            })
            .catch((error) => {
              console.error(error);
            });
        })
        .catch((error) => {
          console.log(error);
        });
      this.$store.commit("setIsLoading", false);
    },
    component_change() {
      this.changed = true;
    },
    history_change() {
      this.history_changed = true;
    },
    confirm_changes() {
      alert("confrim butto");
    },
    cancel_changes() {
      alert("cancel_chan butto");
    },
  },
};
</script>

<style>
#delete-button {
  color: #a0a0a0;
  cursor: pointer;
}
#delete-button:hover {
  color: #dd0000;
}
</style>
