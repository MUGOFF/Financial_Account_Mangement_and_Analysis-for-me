<template>
  <div class="container text-start">
    <div class="m-2">
      <label for="time" class="form-label">시간</label>
      <input
        type="datetime-local"
        class="form-control"
        id="time"
        v-model="transaction.transaction_time"
        :class="{
          'is-invalid':
            try_post === true && transaction.transaction_time === '',
        }"
        aria-describedby="Time-validation"
        required
      />
      <div id="Time-validation" class="invalid-feedback">시간을 입력하세요</div>
    </div>
    <div class="m-2">
      <label for="bank" class="form-label">은행</label>
      <select
        id="bank"
        class="form-select"
        :class="{
          'is-invalid':
            try_post === true && transaction.transaction_from === '',
        }"
        v-model="transaction.transaction_from"
        aria-describedby="Bank-validation"
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
      <div id="Bank-validation" class="invalid-feedback">은행을 선택하세요</div>
    </div>
    <div class="m-2">
      <label for="card" class="form-label">카드</label>
      <select
        id="card"
        class="form-select"
        v-model="transaction.transaction_from_card"
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
          :class="{
            'is-invalid':
              try_post === true &&
              (!exist_history_name || transaction.transaction_to_name === ''),
          }"
          id="to-name"
          list="company-names"
          v-model="transaction.transaction_to_name"
          aria-describedby="To-validation"
          required
        />
        <datalist id="company-names">
          <option
            v-for="(name, index) in company_table"
            :key="index"
            :value="name.company_accountname"
          ></option>
        </datalist>
        <span class="input-group-text">내역 별칭</span>
        <input
          type="text"
          class="form-control"
          :class="{
            'is-invalid':
              try_post_supplier === true &&
              to_company.company_commonname === '',
            'is-valid':
              try_post_supplier === true &&
              to_company.company_commonname !== '',
          }"
          id="to-nickname"
          v-model="to_company.company_commonname"
          aria-describedby="To-Create-validation"
        />
        <button
          class="btn btn-secondary"
          v-if="!exist_history_name"
          @click="post_history_name()"
        >
          등록
        </button>
        <div id="To-validation" class="invalid-feedback">
          유효한 대상을 입력하세요(혹은 새로운 대상을 등록하세요)
        </div>
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
        />
        <span class="input-group-text">고정 항목</span>
        <input
          type="text"
          class="form-control"
          id="to-nickname"
          v-model="to_company.category_hook"
        />
      </div>
    </div>
    <div class="m-2">
      <label for="hashtags" class="form-label">해쉬태그</label>
      <div class="form-control d-flex" id="hashtags">
        <Hashtag
          :hashtags="transaction.sub_category"
          @remove-hashtag="removeHashtag"
        />
        <input
          type="text"
          id="add_hashtag"
          placeholder="Add hashtag"
          :size="newHashtag.length == 0 ? 7 : newHashtag.length"
          v-model="newHashtag"
          @keyup.enter="addHashtag"
        />
      </div>
    </div>
    <div class="m-2">
      <label for="deposit" class="form-label">입금금액</label>
      <input
        type="number"
        class="form-control"
        id="deposit"
        v-model="transaction.deposit_amount"
      />
    </div>
    <div class="m-2">
      <label for="withdrawal" class="form-label"> 출금금액</label>
      <input
        type="number"
        class="form-control"
        id="withdrawal"
        v-model="transaction.withdrawal_amount"
      />
    </div>
    <div class="m-2">
      <label for="description" class="form-label">비고</label>
      <textarea
        type="text"
        class="form-control"
        id="description"
        v-model="transaction.description"
      />
    </div>
    <div class="text-center m-3">
      <button class="btn btn-primary mx-2 btn-lg" @click="confirm_changes()">
        추가
      </button>
      <button class="btn btn-secondary mx-2 btn-lg" @click="cancel_changes()">
        취소
      </button>
    </div>
  </div>

  <!-- Modal -->
  <dialog>
    <form method="dialog">
      <div id="dialog_body" class="container text-start">field_text</div>
      <button class="m-2 btn btn-secondary" value="close">취소</button>
      <button class="m-2 btn btn-warning" value="back">저장하지 않음</button>
      <button class="m-2 btn btn-primary" value="save">저장</button>
    </form>
  </dialog>
</template>
<script>
import Hashtag from "@/components/Hashtag.vue";
import axios from "axios";
const _ = require("lodash");

export default {
  components: {
    Hashtag,
  },
  data() {
    return {
      try_post: false,
      try_post_supplier: false,
      transaction: {
        transaction_time: "",
        transaction_from: "",
        transaction_from_card: "",
        transaction_to_name: "",
        main_category: "미지정",
        sub_category: [],
        deposit_amount: 0,
        withdrawal_amount: 0,
        description: "",
      },
      to_company: {
        company_commonname: "",
        category_hook: "",
      },
      account_table: {},
      card_table: {},
      company_table: {},
      hashtag_table: {},
      newHashtag: "",
    };
  },
  computed: {
    exist_history_name() {
      const company_list = Object.values(this.company_table).map(
        (object) => object.company_accountname
      );
      if (this.transaction.transaction_to_name == "") {
        return true;
      }
      return company_list.includes(this.transaction.transaction_to_name);
    },
  },
  mounted() {
    this.get_table();
    this.get_hastags();
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
    async get_hastags() {
      await axios
        .get("api/v1/hashtag/")
        .then((response) => {
          this.hashtag_table = response.data;
          // console.log(this.transaction);
        })
        .catch((error) => {
          console.log(error);
        });
    },
    // 거래내역 삭제
    delete_transition() {
      const check = confirm("거래내역을 삭제합니까?");
      if (check) {
        axios.delete(
          "api/v1/account_record/Transaction_All/" +
            this.$route.params.transactionId +
            "/"
        );
      }
    },
    // 거래대상 등록
    post_history_name() {
      this.try_post_supplier = true;
      if (this.to_company.company_commonname === "") {
        alert("별칭을 입력하세요");
        return false;
      }
      axios
        .post("api/v1/account_record/Company_nickname/", {
          company_accountname: this.transaction.transaction_to_name,
          company_commonname: this.to_company.company_commonname,
        })
        .then(() => {
          alert("등록 되었습니다.");
          this.get_table();
        })
        .catch((error) => {
          console.error(error);
        });
    },
    addHashtag() {
      if (this.newHashtag.trim() !== "") {
        this.transaction.sub_category.push(this.newHashtag.trim());
        this.newHashtag = "";
      }
    },
    removeHashtag(index) {
      this.transaction.sub_category.splice(index, 1);
      this.changed = true;
    },
    // 최종 버튼 이벤트
    async confirm_changes() {
      this.try_post = true;
      if (this.transaction.transaction_time === "") {
        return false;
      }
      if (this.transaction.transaction_from === "") {
        return false;
      }
      if (this.transaction.transaction_to_name === "") {
        return false;
      }
      if (!this.exist_history_name) {
        return false;
      }
      const check = confirm("거래내역을 추가합니다");
      if (!check) {
        return false;
      }
      const tag_list = Object.values(this.hashtag_table).map(
        (object) => object.sub_category
      );
      const tag_add_list = _.reject(this.transaction.sub_category, (tag) => {
        return tag_list.includes(tag);
      });
      await axios
        .all(
          tag_add_list.map((tag) =>
            axios.post("api/v1/account_record/Hashtag/", { sub_category: tag })
          )
        )
        .catch((error) => {
          console.log(error);
        });
      axios
        .post(
          "api/v1/account_record/Transaction_All/" +
            this.$route.params.transactionId +
            "/",
          {
            transaction_time: this.transaction.transaction_time,
            transaction_from: this.transaction.transaction_from,
            transaction_from_card: this.transaction.transaction_from_card,
            transaction_to_name: this.transaction.transaction_to_name.trim(),
            deposit_amount: this.transaction.deposit_amount,
            withdrawal_amount: this.transaction.withdrawal_amount,
            main_category: this.transaction.main_category,
            sub_category: this.transaction.sub_category,
            description: this.transaction.description,
          }
        )
        .then(() => {
          alert("변경사항이 저장되었습니다");
          this.$router.push({
            name: "TransactionManagement",
            query: {
              year: new Date(this.transaction.transaction_time).getFullYear(),
              month: new Date(this.transaction.transaction_time).getMonth() + 1,
            },
          });
        })
        .catch((error) => {
          console.error(error);
        });
      this.$router.push({
        name: "TransactionManagement",
        query: {
          year: new Date(this.transaction.transaction_time).getFullYear(),
          month: new Date(this.transaction.transaction_time).getMonth() + 1,
        },
      });
    },
    cancel_changes() {
      if (this.changed) {
        const check = confirm("변경사항을 저장하지 않고 나갑니까?");
        if (!check) {
          return false;
        }
      }
      this.$router.push({
        name: "TransactionManagement",
        query: {
          year: new Date(this.transaction.transaction_time).getFullYear(),
          month: new Date(this.transaction.transaction_time).getMonth() + 1,
        },
      });
    },
  },
};
</script>

<style>
#add_hashtag {
  border: 0;
  margin: 0;
  background: #b0b0b0;
}
#delete-button {
  color: #a0a0a0;
  cursor: pointer;
}
#delete-button:hover {
  color: #dd0000;
}
.invalid-content {
  border: red;
}
</style>
