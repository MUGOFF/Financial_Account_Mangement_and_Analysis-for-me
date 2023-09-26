<template>
  <div class="container">
    <button class="mb-2 btn btn-sm btn-success" @click="YearOrMonth()">
      <span v-if="yearly">연간</span>
      <span v-else>월간</span>
    </button>
    <ul class="pagination justify-content-center">
      <li class="datebuttongroup">
        <a
          class="datebutton"
          href="#"
          aria-label="Previous"
          @click.prevent="PreviousYear()"
        >
          <span class="datetext" aria-hidden="true">&laquo;</span>
        </a>
      </li>
      <li class="datebuttongroup" v-if="!yearly">
        <a
          class="datebutton"
          href="#"
          aria-label="Previous"
          @click.prevent="PreviousMonth()"
        >
          <span class="datetext" aria-hidden="true">&lsaquo;</span>
        </a>
      </li>
      <li class="datetextgroup">
        <input
          type="text"
          v-model="yearmonth.year"
          id="yearmonth"
          class="datetext"
          maxlength="4"
          style="width: 5rem"
          @change="changemonth()"
        />
        <span>.</span>
        <input
          type="text"
          v-model="yearmonth.month"
          id="yearmonth"
          class="datetext"
          maxlength="2"
          style="width: 3rem"
          v-if="!yearly"
          @change="changemonth()"
        />
      </li>
      <li class="datebuttongroup" v-if="!yearly">
        <a
          class="datebutton"
          href="#"
          aria-label="Previous"
          @click.prevent="NextMonth()"
        >
          <span class="datetext" aria-hidden="true">&rsaquo;</span>
        </a>
      </li>
      <li class="datebuttongroup">
        <a
          class="datebutton"
          href="#"
          aria-label="Next"
          @click.prevent="NextYear()"
        >
          <span class="datetext" aria-hidden="true">&raquo;</span>
        </a>
      </li>
    </ul>
    <div class="d-flex flex-row-reverse">
      <button class="mb-2 btn btn-primary" @click="MovetoCreate()">
        거래기록 생성하기
      </button>
      <div>
        <input type="checkbox" id="supplier" v-model="null_supplier_check" />
        <label for="supplier">거래 대상 미입력</label>
      </div>
    </div>
    <div
      v-if="Filter_Transactions.length === 0 && !this.$store.state.isLoading"
    >
      거래기록이 존재하지 않습니다
    </div>
    <div v-for="(date, index) in Transaction_exist_Date" :key="index">
      <p
        class="text-center bg-light fw-bold fs-4"
        data-bs-toggle="collapse"
        :data-bs-target="'#date' + date + 'transaction'"
        aria-expanded="true"
        :aria-controls="'date' + date + 'transaction'"
      >
        {{ date[0] }}월 {{ date[1] }}일
      </p>
      <div
        class="table-responsive collapse show"
        :id="'date' + date + 'transaction'"
      >
        <table class="table tableborderd table-hover table-sm">
          <thead>
            <tr>
              <th>No</th>
              <th>시간</th>
              <th>은행</th>
              <th>카드</th>
              <th>거래내역</th>
              <th>입금금액</th>
              <th>출금금액</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(transaction, tindex) in Date_filter_Transactions(
                date[0],
                date[1]
              )"
              :key="tindex"
              @click="linkdetail(transaction.id)"
            >
              <td>{{ tindex + 1 }}</td>
              <td>
                {{ new Date(transaction.transaction_time).getHours() }}시
                {{ new Date(transaction.transaction_time).getMinutes() }}분
              </td>
              <td>{{ transaction.transaction_from_str }}</td>
              <td>
                {{
                  transaction.transaction_from_card_str
                    ? transaction.transaction_from_card_str
                    : "-"
                }}
              </td>
              <td>{{ transaction.transaction_to_name }}</td>
              <td>{{ transaction.deposit_amount }}</td>
              <td>{{ transaction.withdrawal_amount }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import axios from "axios";
const _ = require("lodash");

export default {
  // this.$route.params
  data() {
    return {
      yearmonth: {
        year: this.$route.query.year
          ? this.$route.query.year
          : new Date().getFullYear(),
        month: this.$route.query.month
          ? String(this.$route.query.month).padStart(2, "0")
          : String(new Date().getMonth() + 1).padStart(2, "0"),
      },
      yearmonth_old: {
        year: this.$route.query.year
          ? this.$route.query.year
          : new Date().getFullYear(),
        month: this.$route.query.month
          ? String(this.$route.query.month).padStart(2, "0")
          : String(new Date().getMonth() + 1).padStart(2, "0"),
      },
      transaction_all: [],
      null_supplier_check: false,
      yearly: false,
    };
  },
  computed: {
    Filter_Transactions() {
      let filtered_transaction;
      if (this.yearly) {
        filtered_transaction = this.transaction_all.filter((transaction) => {
          const itemYear = new Date(transaction.transaction_time).getFullYear();
          return itemYear === Number(this.yearmonth.year);
        });
      } else {
        filtered_transaction = this.transaction_all.filter((transaction) => {
          const itemMonth =
            new Date(transaction.transaction_time).getMonth() + 1;
          return itemMonth === Number(this.yearmonth.month);
        });
      }
      if (this.null_supplier_check) {
        console.log(
          filtered_transaction.filter(
            (transaction) => transaction.transaction_to_name === null
          )
        );
        return filtered_transaction.filter(
          (transaction) => transaction.transaction_to_name === null
        );
      } else {
        return filtered_transaction;
      }
    },
    Transaction_exist_Date() {
      const exist_day = this.Filter_Transactions.map((transaction) => {
        return [
          new Date(transaction.transaction_time).getMonth() + 1,
          new Date(transaction.transaction_time).getDate(),
        ].toString();
      });
      return [...new Set(exist_day)].map((date) => date.split(","));
    },
  },
  mounted() {
    this.get_transaction(this.yearmonth.year, this.yearmonth.month);
  },
  methods: {
    async get_transaction(year, month) {
      this.$store.commit("setIsLoading", true);
      await axios
        .get("api/v1/account_transaction/" + year + "/" + month + "/")
        .then((response) => {
          this.transaction_all = response.data;
          // console.log(response.data);
        })
        .catch((error) => {
          console.log(error);
        });
      this.$store.commit("setIsLoading", false);
    },
    async get_yearly_transaction(year) {
      this.$store.commit("setIsLoading", true);
      await axios
        .get("api/v1/account_transaction/" + year + "/")
        .then((response) => {
          this.transaction_all = response.data;
          // console.log(response.data);
        })
        .catch((error) => {
          console.log(error);
        });
      this.$store.commit("setIsLoading", false);
    },
    changemonth() {
      const regyear = /[0-9]{4}/;
      const regmonth = /[0-9]{2}/;
      if (
        !regyear.test(this.yearmonth.year) ||
        !regmonth.test(this.yearmonth.month)
      ) {
        this.yearmonth = _.cloneDeep(this.yearmonth_old);
        return false;
      }
      this.yearmonth_old = _.cloneDeep(this.yearmonth);
    },
    Date_filter_Transactions(month, day) {
      const filtered_transaction = this.transaction_all.filter(
        (transaction) => {
          const itemDate = new Date(transaction.transaction_time).getDate();
          const itemMonth =
            new Date(transaction.transaction_time).getMonth() + 1;
          return itemDate === Number(day) && itemMonth === Number(month);
        }
      );
      if (this.null_supplier_check) {
        console.log(
          filtered_transaction.filter(
            (transaction) => transaction.transaction_to_name === null
          )
        );
        return filtered_transaction.filter(
          (transaction) => transaction.transaction_to_name === null
        );
      } else {
        return filtered_transaction;
      }
    },
    MovetoCreate() {
      this.$router.push({
        name: "TransactionCreate",
      });
    },
    linkdetail(transaction_Id) {
      this.$router.push({
        name: "TransactionDetail",
        params: {
          transactionId: transaction_Id,
        },
      });
    },
    YearOrMonth() {
      this.yearly = !this.yearly;
      if (this.yearly) {
        this.get_yearly_transaction(this.yearmonth.year);
      } else {
        this.get_transaction(this.yearmonth.year, this.yearmonth.month);
      }
    },
    PreviousYear() {
      this.yearmonth.year--;
      this.yearmonth_old.year--;
      if (this.yearly) {
        this.get_yearly_transaction(this.yearmonth.year);
      } else {
        this.get_transaction(this.yearmonth.year, this.yearmonth.month);
      }
    },
    NextYear() {
      this.yearmonth.year++;
      this.yearmonth_old.year++;
      if (this.yearly) {
        this.get_yearly_transaction(this.yearmonth.year);
      } else {
        this.get_transaction(this.yearmonth.year, this.yearmonth.month);
      }
    },
    PreviousMonth() {
      if (this.yearmonth.month === "01") {
        this.PreviousYear();
        this.yearmonth.month = "12";
      } else {
        this.yearmonth.month = String(
          Number(this.yearmonth.month) - 1
        ).padStart(2, "0");
        this.yearmonth_old.month = String(
          Number(this.yearmonth_old.month) - 1
        ).padStart(2, "0");
      }
      this.get_transaction(this.yearmonth.year, this.yearmonth.month);
    },
    NextMonth() {
      if (this.yearmonth.month === "12") {
        this.NextYear();
        this.yearmonth.month = "01";
      } else {
        this.yearmonth.month = String(
          Number(this.yearmonth.month) + 1
        ).padStart(2, "0");
        this.yearmonth_old.month = String(
          Number(this.yearmonth_old.month) + 1
        ).padStart(2, "0");
      }
      this.get_transaction(this.yearmonth.year, this.yearmonth.month);
    },
  },
};
</script>
<style>
.datetext {
  border: none;
  padding: none;
  text-align: center;
  line-height: 1;
  font-size: 30px;
  margin: 0;
}
.datebutton {
  text-decoration: none;
  color: black;
}
.datebutton:hover {
  color: black;
}
.datetextgroup {
  margin: 0 20px;
}
.datebuttongroup {
  width: 2.4rem;
  height: 2.4rem;
  vertical-align: middle;
  text-align: center;
  margin: 0 10px;
}
.datebuttongroup:hover {
  width: 2.4rem;
  height: 2.4rem;
  vertical-align: middle;
  text-align: center;
  box-shadow: 1px 1px 2px gray;
  border-radius: 20%;
  margin: 0 10px;
}
</style>
