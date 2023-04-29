<!-- calendar -->
<template>
  <div class="container">
    <VCalendar
      :expanded="isExpanded"
      :attributes="attributes"
      ref="date"
      @transition-start="month_now()"
      @update:pages="ref_check()"
    />
  </div>
</template>

<script>
import { VCalendar } from "v-calendar";
import { ref } from "vue";
const _ = require("lodash");

export default {
  name: "TransactionCalendar",
  components: {
    VCalendar,
  },
  data() {
    return {
      date: ref(null),
      attributes: [
        {
          key: "today",
          highlight: {
            color: "purple",
            fillMode: "solid",
            contentClass: "italic",
          },
          dates: new Date(),
        },
        {
          key: "withdrawal",
          dot: "red",
          dates: this.withdrawal,
        },
        {
          key: "deposit",
          dot: "green",
          dates: this.deposit,
        },
      ],
    };
  },
  props: {
    deposit: {
      type: Array,
      default: () => {},
    },
    withdrawal: {
      type: Array,
      default: () => {},
    },
    isExpanded: {
      type: Boolean,
      default: () => false,
    },
  },
  methods: {
    ref_check() {
      _.find(this.attributes, { key: "deposit" }).dates = this.deposit;
      _.find(this.attributes, { key: "withdrawal" }).dates = this.withdrawal;
    },
    month_now() {
      this.$emit(
        "month_year",
        this.$refs.date.pages[0].month,
        this.$refs.date.pages[0].year
      );
    },
  },
};
</script>
