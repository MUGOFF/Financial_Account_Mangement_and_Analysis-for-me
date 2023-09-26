<template>
  <div class="container">
    <div class="d-flex justify-content-between">
      <div>
        <router-link
          :to="{
            name: 'BudgetView',
            query: {
              year: date_now.year,
              month: date_now.month,
            },
          }"
        >
          <img :src="require('@/assets/ICONs/To_budget icon.png')" width="90" />
        </router-link>
      </div>
      <div>
        <input type="checkbox" id="picker" v-model="picker" />
        <label for="picker">날짜 범위 선택</label>
      </div>
    </div>
    <!-- calendar -->
    <TransactionCalendar
      class="mb-4"
      :isExpanded="true"
      :isDatepicker="picker"
      :date_now="date_now"
      :deposit="deposit_days"
      :withdrawal="withdrawal_days"
      @send_range="set_range"
      @month_year="get_monthly_transactions"
    />
    <!-- table -->
    <div v-for="(date, index) in Transaction_exist_Date" :key="index">
      <div
        class="table-responsive collapse show"
        :id="'date' + date + 'transaction'"
      >
        <table class="table tableborderd table-sm">
          <thead>
            <tr>
              <th colspan="5">{{ this.date_now.month }}월 {{ date }}일</th>
            </tr>
          </thead>
          <tbody>
            <template
              v-for="(transaction, tindex) in Date_filter_Transactions(date)"
              :key="tindex"
            >
              <tr>
                <th rowspan="2" class="align-middle col-1">
                  <img
                    :src="
                      require('@/assets/CIs/' +
                        transaction.transaction_from_type +
                        'CI.png')
                    "
                    width="40"
                  />
                  <img
                    v-if="transaction.transaction_from_card_str"
                    :src="
                      require('@/assets/CIs/' +
                        transaction.transaction_from_card_type +
                        'CI.png')
                    "
                    width="40"
                  />
                </th>
                <!-- <td>
                  {{ new Date(transaction.transaction_time).getHours() }}시
                  {{ new Date(transaction.transaction_time).getMinutes() }}분
                </td> -->
                <td class="col-4" style="border: none">
                  {{ transaction.transaction_to_name }}
                </td>
                <td
                  class="col-2"
                  style="border: none; cursor: pointer"
                  data-bs-toggle="modal"
                  data-bs-target="#category-select"
                  @click="main_category_select_modal(transaction)"
                >
                  {{ transaction.main_category }}
                </td>
                <td
                  v-if="transaction.deposit_amount !== 0"
                  rowspan="2"
                  :style="{
                    color: this.main_in_flow(transaction.main_category, '이체')
                      ? 'gray'
                      : 'green',
                  }"
                  class="align-middle col-2"
                >
                  + {{ transaction.deposit_amount.toLocaleString() }} &#8361;
                </td>
                <td
                  v-if="transaction.withdrawal_amount !== 0"
                  rowspan="2"
                  :style="{
                    color: this.main_in_flow(transaction.main_category, '이체')
                      ? 'gray'
                      : 'red',
                  }"
                  class="align-middle col-2"
                >
                  - {{ transaction.withdrawal_amount.toLocaleString() }} &#8361;
                </td>
              </tr>
              <tr>
                <td colspan="2">
                  <span v-if="transaction.sub_category.length === 0">-</span>
                  <Hashtag v-else :hashtags="transaction.sub_category" />
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
    </div>
    <!-- table end -->
    <!-- Modalstart bootstrap -->
    <div
      class="modal fade"
      id="category-select"
      data-bs-backdrop="static"
      data-bs-keyboard="false"
      tabindex="-1"
      aria-labelledby="CategorySelectLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="CategorySelectLabel">
              거래 항목 설정
            </h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <ul class="nav nav-tabs">
              <li class="nav-item">
                <label
                  class="nav-link"
                  :class="{ active: add_form.flow === '수입' }"
                  for="income"
                  >수입</label
                ><input
                  id="income"
                  class="invisible"
                  type="radio"
                  name="flow"
                  v-model="add_form.flow"
                  value="수입"
                  checked
                />
              </li>
              <li class="nav-item">
                <label
                  class="nav-link"
                  :class="{ active: add_form.flow === '소비' }"
                  for="consume"
                  >소비</label
                ><input
                  id="consume"
                  class="invisible"
                  type="radio"
                  name="flow"
                  v-model="add_form.flow"
                  value="소비"
                />
              </li>
              <li class="nav-item">
                <label
                  class="nav-link"
                  :class="{ active: add_form.flow === '이체' }"
                  for="transfer"
                  >이체</label
                ><input
                  id="transfer"
                  class="invisible"
                  type="radio"
                  name="flow"
                  v-model="add_form.flow"
                  value="이체"
                />
              </li>
            </ul>
            <ul class="list-group">
              <button
                class="list-group-item"
                aria-current="true"
                :class="{ active: selected_data.main_category === category }"
                v-for="(category, index) in category_each"
                :key="index"
                :value="category"
                @click="main_category_select(category)"
                data-bs-dismiss="modal"
              >
                {{ category }}
              </button>
              <li class="list-group-item" @click="main_category_modal()">
                항목 추가
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    <!-- Modalend -->
    <!-- Modal -->
    <dialog>
      <form method="dialog">
        <div id="dialog_body" class="container text-start">
          <div class="input-group m-1">
            <span class="input-group-text">대항목</span>
            <input
              type="text"
              class="form-control"
              v-model="add_form.flow"
              readonly
            />
          </div>
          <div class="input-group m-1">
            <span class="input-group-text">항목</span>
            <input type="text" v-model="add_form.main" class="form-control" />
          </div>
        </div>
        <button class="m-2 btn btn-secondary" value="close">취소</button>
        <button class="m-2 btn btn-info" value="confirm">추가</button>
      </form>
    </dialog>
  </div>
</template>

<script>
import axios from "axios";
import TransactionCalendar from "@/components/TransactionCalendar.vue";
import Hashtag from "@/components/Hashtag.vue";
const _ = require("lodash");

export default {
  components: {
    TransactionCalendar,
    Hashtag,
  },
  data() {
    return {
      date_now: {
        year: this.$route.query.year
          ? this.$route.query.year
          : new Date().getFullYear(),
        month: this.$route.query.month
          ? this.$route.query.month
          : new Date().getMonth() + 1,
      },
      date_range: {
        start: 0,
        end: 31,
      },
      add_form: {
        flow: "소비",
        main: "",
      },
      picker: false,
      selected_data: {},
      transaction_data: [],
      category_table: [],
    };
  },
  computed: {
    category_each() {
      const consume = this.category_table
        .filter((category) => category.flow_category === this.add_form.flow)
        .map((category) => category.main_category);
      return consume;
    },
    Transaction_data_include_picker() {
      if (this.picker) {
        const ranged_data = this.transaction_data.filter(
          (transaction) =>
            new Date(transaction.transaction_time).getDate() >=
              this.date_range.start &&
            new Date(transaction.transaction_time).getDate() <=
              this.date_range.end
        );
        return ranged_data;
      } else {
        return this.transaction_data;
      }
    },
    Transaction_exist_Date() {
      const days = new Date(
        this.date_now.year,
        this.date_now.month,
        0
      ).getDate();
      const exist_day = this.Transaction_data_include_picker.map(
        (transaction) => new Date(transaction.transaction_time).getDate()
      );
      return _.range(1, days + 1).filter((n) => exist_day.includes(n));
    },
    deposit_days() {
      const transactions = this.transaction_data.filter(
        (transaction) => transaction.deposit_amount > 0
      );
      const dates = transactions.map(
        (transaction) => new Date(transaction.transaction_time)
      );
      return _.uniqBy(dates, (date) => date.getDate());
    },
    withdrawal_days() {
      const transactions = this.transaction_data.filter(
        (transaction) => transaction.withdrawal_amount > 0
      );
      const dates = transactions.map(
        (transaction) => new Date(transaction.transaction_time)
      );
      return _.uniqBy(dates, (date) => date.getDate());
    },
  },
  created() {
    this.get_monthly_transactions(this.date_now.month, this.date_now.year);
    this.get_category();
  },
  methods: {
    async get_monthly_transactions(month, year) {
      this.picker = false;
      this.date_range.start = 0;
      this.date_range.end = 31;
      this.date_now.year = year;
      this.date_now.month = month;
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
    get_category() {
      axios
        .get("api/v1/account_record/Category/")
        .then((response) => {
          this.category_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
    },
    Date_filter_Transactions(day) {
      const filtered_transaction = this.transaction_data.filter(
        (transaction) =>
          Date.parse(transaction.transaction_time) >
            Date.parse(
              this.date_now.year +
                " " +
                this.date_now.month +
                " " +
                day +
                " 00:00:00"
            ) &&
          Date.parse(transaction.transaction_time) <
            Date.parse(
              this.date_now.year +
                " " +
                this.date_now.month +
                " " +
                (day + 1) +
                " 00:00:00"
            )
      );
      return filtered_transaction;
    },
    main_in_flow(category, flow) {
      const flow_table = this.category_table.filter(
        (category) => category.flow_category === flow
      );
      const flow_table_main = flow_table.map((flow) => flow.main_category);
      return flow_table_main.includes(category);
    },
    // 항목 모달열기
    main_category_select_modal(data) {
      this.selected_data = data;
    },
    // 항목 반영
    main_category_select(data) {
      this.selected_data.main_category = data;
      axios.put(
        "api/v1/account_record/Transaction_All/" + this.selected_data.id + "/",
        {
          transaction_time: this.selected_data.transaction_time,
          transaction_from: this.selected_data.transaction_from,
          transaction_from_card: this.selected_data.transaction_from_card,
          transaction_to_name: this.selected_data.transaction_to_name.trim(),
          deposit_amount: this.selected_data.deposit_amount,
          withdrawal_amount: this.selected_data.withdrawal_amount,
          main_category: this.selected_data.main_category,
          sub_category: this.selected_data.sub_category,
          description: this.selected_data.description,
        }
      );
    },
    // 항목 추기 모달열기
    main_category_modal() {
      const dialog = document.querySelector("dialog");
      dialog.addEventListener(
        "close",
        () => {
          const value = dialog.returnValue;
          if (value === "confirm") {
            const main = this.add_form.main.trim();
            if (main === "") {
              alert("입력된 값이 없습니다");
              return false;
            }
            if (this.category_each.includes(main)) {
              alert("이미 존재하는 항목입니다");
              return false;
            }
            axios
              .post("api/v1/account_record/Category/", {
                flow_category: this.add_form.flow,
                main_category: main,
              })
              .then(() => {
                this.add_form.main = "";
                axios
                  .get("api/v1/account_record/Category/")
                  .then((response) => {
                    this.category_table = response.data;
                  });
              });
          }
        },
        { once: true }
      );
      dialog.showModal();
    },
    // 날짜 범위 세팅
    set_range(start, end) {
      this.date_range.start = start;
      this.date_range.end = end;
    },
  },
};
</script>
