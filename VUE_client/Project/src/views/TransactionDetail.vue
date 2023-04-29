<template>
  <div class="container text-start">
    <div id="delete-button" class="text-end" @click="delete_transition()">
      x 거래내역 삭제
    </div>
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
        <button
          class="btn btn-secondary"
          v-if="!exist_history_name"
          @click="post_history_name()"
        >
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
      <div
        class="form-control d-flex"
        id="hashtags"
        @change="component_change()"
      >
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
      changed: false,
      history_changed: false,
      transaction: {},
      to_company: {},
      account_table: {},
      card_table: {},
      company_table: {},
      hashtag_table: {},
      newHashtag: "",
    };
  },
  computed: {
    exist_history_name() {
      const company_lsit = Object.values(this.company_table).map(
        (object) => object.company_accountname
      );
      return company_lsit.includes(this.transaction.transaction_to_name);
    },
  },
  mounted() {
    this.get_table();
    this.import_transaction_data();
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
          // console.log(this.transaction);
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
      axios
        .post("api/v1/account_record/Company_nickname/", {
          company_accountname: this.transaction.transaction_to_name,
          company_commonname: this.transaction.transaction_to_name,
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
      if (this.changed) {
        const check = confirm("변경사항을 저장합니다");
        if (!check) {
          return false;
        }
        axios
          .put(
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
                month:
                  new Date(this.transaction.transaction_time).getMonth() + 1,
              },
            });
          })
          .catch((error) => {
            console.error(error);
          });
      } else {
        this.$router.push({
          name: "TransactionManagement",
          query: {
            year: new Date(this.transaction.transaction_time).getFullYear(),
            month: new Date(this.transaction.transaction_time).getMonth() + 1,
          },
        });
      }
      // endif
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
    // 변화 표시
    component_change() {
      this.changed = true;
    },
    history_change() {
      this.history_changed = true;
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
</style>
