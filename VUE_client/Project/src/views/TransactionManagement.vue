<template>
  <div class="container">
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
      <li class="datebuttongroup">
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
          @change="changemonth()"
        />
      </li>
      <li class="datebuttongroup">
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
    <div
      class="spinner-border"
      role="status"
      v-show="this.$store.state.isLoading"
      style="width: 10vh; height: 10vh"
    >
      <span class="visually-hidden">Loading...</span>
    </div>
    <div
      v-if="
        Month_filter_Transactions.length === 0 && !this.$store.state.isLoading
      "
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
        {{ this.yearmonth.month }}월 {{ date }}일
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
              v-for="(transaction, tindex) in Date_filter_Transactions(date)"
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
        year: new Date().getFullYear(),
        month: String(new Date().getMonth() + 1).padStart(2, "0"),
      },
      yearmonth_old: {
        year: new Date().getFullYear(),
        month: String(new Date().getMonth() + 1).padStart(2, "0"),
      },
      transaction_all: [],
    };
  },
  computed: {
    Month_filter_Transactions() {
      const filtered_transaction = this.transaction_all.filter(
        (transaction) =>
          Date.parse(transaction.transaction_time) >
            Date.parse(
              this.yearmonth.year + " " + this.yearmonth.month + " 01 00:00:00"
            ) &&
          Date.parse(transaction.transaction_time) <
            Date.parse(
              this.yearmonth.year +
                " " +
                String(Number(this.yearmonth.month) + 1) +
                " 01 00:00:00"
            )
      );
      return filtered_transaction;
    },
    Transaction_exist_Date() {
      const days = new Date(
        this.yearmonth.year,
        this.yearmonth.month,
        0
      ).getDate();
      const exist_day = this.Month_filter_Transactions.map((transaction) =>
        new Date(transaction.transaction_time).getDate()
      );
      return _.range(1, days + 1).filter((n) => exist_day.includes(n));
    },
  },
  mounted() {
    this.get_transaction();
  },
  methods: {
    async get_transaction() {
      this.$store.commit("setIsLoading", true);
      await axios
        .get("api/v1/account_record/Transaction_All/")
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
    Date_filter_Transactions(day) {
      const filtered_transaction = this.transaction_all.filter(
        (transaction) =>
          Date.parse(transaction.transaction_time) >
            Date.parse(
              this.yearmonth.year +
                " " +
                this.yearmonth.month +
                " " +
                day +
                " 00:00:00"
            ) &&
          Date.parse(transaction.transaction_time) <
            Date.parse(
              this.yearmonth.year +
                " " +
                this.yearmonth.month +
                " " +
                (day + 1) +
                " 00:00:00"
            )
      );
      this.$store.commit("setIsLoading", false);
      return filtered_transaction;
    },
    linkdetail(transaction_Id) {
      this.$router.push({
        name: "TransactionDetail",
        params: {
          transactionId: transaction_Id,
        },
      });
    },
    PreviousYear() {
      this.yearmonth.year--;
      this.yearmonth_old.year--;
    },
    NextYear() {
      this.yearmonth.year++;
      this.yearmonth_old.year++;
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
