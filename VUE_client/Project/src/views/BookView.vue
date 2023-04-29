<template>
  <!-- calendar -->
  <TransactionCalendar
    :isExpanded="true"
    :deposit="deposit_days"
    :withdrawal="withdrawal_days"
    @month_year="get_monthly_transactions"
  />
</template>

<script>
import axios from "axios";
import TransactionCalendar from "@/components/TransactionCalendar.vue";
const _ = require("lodash");

export default {
  components: {
    TransactionCalendar,
  },
  data() {
    return {
      date_now: new Date(),
      transaction_data: [],
    };
  },
  computed: {
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
    this.get_monthly_transactions(
      this.date_now.getMonth() + 1,
      this.date_now.getFullYear()
    );
  },
  methods: {
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
  },
};
</script>
