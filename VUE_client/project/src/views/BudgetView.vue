<template>
  <div class="container">
    <div>
      <router-link
        :to="{
          name: 'BookView',
          query: {
            year: date_now.year,
            month: date_now.month,
          },
        }"
      >
        <img
          :src="require('@/assets/ICONs/To_budget_back icon.png')"
          width="90"
        />
      </router-link>
    </div>
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
        <span type="text" id="yearmonth" class="datetext"
          >{{ date_now.year }}년 {{ date_now.month }}월</span
        >
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
    <div>1</div>
    <div class="d-flex">
      <div class="col-8" role="chart" id="chartdiv">
        <BookChart
          :TransactionData="transaction_data"
          :year="Number(date_now.year)"
          :month="Number(date_now.month)"
        />
      </div>
      <!-- tablediv -->
      <div class="col-4" id="tablediv">
        <!-- table -->
        <div v-if="has_settings">
          <table class="table table-borderless table-responsive">
            <thead>
              <tr>
                <th>종류</th>
                <th>금액</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(key, index) in Object.keys(book_settings.components)"
                :key="index"
              >
                <td>{{ key }}</td>
                <td>
                  <div class="progress">
                    <div
                      class="progress-bar progress-bar-striped"
                      role="progressbar"
                      style="width: 100%"
                      aria-valuenow="20"
                      aria-valuemin="0"
                      aria-valuemax="100"
                    >
                      {{
                        book_settings.components[key].toLocaleString("ko-KR", {
                          style: "currency",
                          currency: "KRW",
                        })
                      }}
                      {{ consum_from_main_category(key) }}
                    </div>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <!-- table end -->
        <!-- button -->
        <div>
          <button
            v-if="!has_settings"
            class="btn btn-lg btn-success"
            data-bs-toggle="modal"
            data-bs-target="#BudgetTable"
            style="background-color: #2fba36"
          >
            예산 설정
          </button>
          <button
            v-else
            class="btn btn-success"
            data-bs-toggle="modal"
            data-bs-target="#BudgetTable"
            style="background-color: #2fba36"
          >
            예산 변경
          </button>
        </div>
        <!-- button end -->
      </div>
      <!-- tablediv end -->
    </div>
  </div>

  <!-- Modalstart bootstrap -->
  <div
    class="modal fade"
    id="BudgetTable"
    data-bs-backdrop="static"
    data-bs-keyboard="false"
    tabindex="-1"
    aria-labelledby="BudgetTableLabel"
    aria-hidden="true"
  >
    <div class="modal-dialog w-50">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="BudgetTableLabel">예산 설정</h1>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>
        <form id="modal_form" @submit.prevent="set_budget()">
          <div class="modal-body">
            <div class="input-group mb-2">
              <label class="form-label mx-2">총 예산</label>
              <input
                type="number"
                class="form-control"
                v-model="book_settings.total"
                required
              />
            </div>
            <div>
              <table class="table table-borderless table-responsive">
                <thead>
                  <tr>
                    <th class="col-2">종류</th>
                    <th class="col-4">금액</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(category, index) in category_comsume"
                    :key="index"
                  >
                    <td class="col-2">{{ category.main_category }}</td>
                    <td class="col-4">
                      <div class="input-group">
                        <CurrecyLocale
                          class="form-control"
                          style="width: 200px"
                          v-model="
                            book_settings.components[category.main_category]
                          "
                        ></CurrecyLocale>
                        <span
                          class="input-group-text"
                          style="cursor: pointer"
                          @click="multi_budget(category.main_category, 1000)"
                          >X천</span
                        >
                        <span
                          class="input-group-text"
                          style="cursor: pointer"
                          @click="multi_budget(category.main_category, 10000)"
                          >X만</span
                        >
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              data-bs-dismiss="modal"
            >
              닫기
            </button>
            <button type="submit" class="btn btn-primary">설정</button>
          </div>
        </form>
      </div>
    </div>
  </div>
  <!-- Modalend -->
</template>
<script>
import CurrecyLocale from "@/components/CurrencyNumberInput.vue";
import BookChart from "@/components/BookChart.vue";
import axios from "axios";
const _ = require("lodash");

export default {
  name: "BudgetView",
  components: {
    CurrecyLocale,
    BookChart,
  },
  data() {
    return {
      has_settings: false,
      date_now: {
        year: this.$route.query.year
          ? this.$route.query.year
          : new Date().getFullYear(),
        month: this.$route.query.month
          ? this.$route.query.month
          : new Date().getMonth() + 1,
      },
      book_settings: {
        total: 0,
        components: {},
      },
      book_settings_p: {
        total: 0,
        components: {},
      },
      category_table: [],
      transaction_data: [],
      transaction_data_p: [],
    };
  },
  watch: {
    "book_settings.total": function () {
      if (_.isEmpty(this.book_settings.components)) {
        if (this.book_settings.total < 0 || this.book_settings.total === "") {
          this.book_settings.total = 0;
        }
      } else {
        const budget_sum = Object.values(this.book_settings.components).reduce(
          (accumulator, currentValue) => accumulator + currentValue
        );
        if (this.book_settings.total < 0 || this.book_settings.total === "") {
          this.book_settings.total = 0;
        }
        if (budget_sum > this.book_settings.total) {
          this.book_settings.total = budget_sum;
        }
      }
    },
    "book_settings.components": {
      handler: function () {
        for (const [key, value] of Object.entries(
          this.book_settings.components
        )) {
          if (value < 0 || value === "") {
            this.book_settings.components[key] = 0;
          }
        }
        const budget_sum = Object.values(this.book_settings.components).reduce(
          (accumulator, currentValue) => accumulator + currentValue
        );
        if (budget_sum > this.book_settings.total) {
          this.book_settings.total = budget_sum;
        }
      },
      // handler end
      deep: true,
    },
  },
  computed: {
    category_comsume() {
      const consume = this.category_table.filter(
        (category) => category.flow_category === "소비"
      );
      return consume;
    },
  },
  mounted() {
    this.get_category();
    this.get_import_month_data_set();
    this.get_monthly_transactions_previous(
      this.date_now.month,
      this.date_now.year
    );
  },
  methods: {
    // data import
    get_import_month_data_set() {
      this.get_budget_settings(this.date_now.month, this.date_now.year);
      this.get_monthly_transactions(this.date_now.month, this.date_now.year);
    },
    get_budget_settings(month, year) {
      axios
        .get("api/v1/booksetting/" + year + "/" + month + "/")
        .then((response) => {
          if (_.isEmpty(response.data)) {
            this.has_settings = false;
          } else {
            this.has_settings = true;
            this.book_settings = response.data[0]["string_to_json"];
          }
        });
    },
    get_category() {
      axios.get("api/v1/account_record/Category/").then((response) => {
        this.category_table = response.data;
      });
    },
    async get_monthly_transactions(month, year) {
      this.$store.commit("setIsLoading", true);
      await axios
        .get("api/v1/account_transaction/" + year + "/" + month + "/")
        .then((response) => {
          this.transaction_data = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      this.$store.commit("setIsLoading", false);
    },
    async get_monthly_transactions_previous(month, year) {
      this.$store.commit("setIsLoading", true);
      await axios
        .get(
          "api/v1/account_transaction/" + year + "/" + String(month - 1) + "/"
        )
        .then((response) => {
          this.transaction_data_p = response.data;
        });
      await axios
        .get("api/v1/booksetting/" + year + "/" + String(month - 1) + "/")
        .then((response) => {
          if (!_.isEmpty(response.data)) {
            this.book_settings_p = response.data[0]["string_to_json"];
          }
        });
      this.$store.commit("setIsLoading", false);
    },
    // 예산 설정 모달 관련
    set_budget() {
      if (this.has_settings) {
        axios
          .put(
            "api/v1/booksetting/" +
              this.date_now.year +
              "/" +
              this.date_now.month +
              "/",
            {
              year: this.date_now.year,
              month: this.date_now.month,
              json_string: JSON.stringify(this.book_settings),
            }
          )
          .then(alert("예산이 변경되었습니다"));
      } else {
        axios
          .post(
            "api/v1/booksetting/" +
              this.date_now.year +
              "/" +
              this.date_now.month +
              "/",
            {
              year: this.date_now.year,
              month: this.date_now.month,
              json_string: JSON.stringify(this.book_settings),
            }
          )
          .then(alert("예산이 설정되었습니다"))
          .catch((error) => {
            console.error(error);
          });
        this.has_settings = true;
      }
    },
    multi_budget(key, multiply = 2) {
      if (key === undefined) {
        alert("값이 설정되지 않았습니다");
        return false;
      }
      if (this.book_settings.components[key] * multiply >= Math.pow(10000, 3)) {
        alert("최댓값을 넘었습니다");
        return false;
      }
      this.book_settings.components[key] =
        this.book_settings.components[key] * multiply;
    },
    consum_from_main_category(category) {
      const consume = this.transaction_data.filter(
        (transaction) => transaction.main_category === category
      );
      if (_.isEmpty(consume)) {
        return 0;
      } else {
        let budget_sum = 0;
        consume.forEach(
          (transaction) =>
            (budget_sum = budget_sum + transaction.withdrawal_amount)
        );
        return budget_sum;
      }
    },
    // 날짜 변환
    PreviousYear() {
      this.date_now.year--;
      this.get_import_month_data_set();
    },
    NextYear() {
      this.date_now.year++;
      this.get_import_month_data_set();
    },
    PreviousMonth() {
      if (this.date_now.month === 1) {
        this.PreviousYear();
        this.date_now.month = 12;
      } else {
        this.date_now.month--;
      }
      this.get_import_month_data_set();
    },
    NextMonth() {
      if (this.date_now.month === 12) {
        this.NextYear();
        this.date_now.month = 1;
      } else {
        this.date_now.month++;
      }
      this.get_import_month_data_set();
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
  cursor: pointer;
}
</style>
