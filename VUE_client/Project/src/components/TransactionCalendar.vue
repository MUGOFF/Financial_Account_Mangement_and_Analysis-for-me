<!-- calendar -->
<template>
  <div class="container">
    <DatePicker
      v-if="isDatepicker"
      :initial-page="{ month: date_now.month, year: date_now.year }"
      :expanded="isExpanded"
      :attributes="attributes"
      :select-attribute="selectDragAttribute"
      :drag-attribute="selectDragAttribute"
      ref="date"
      v-model.range="date_pick"
      @transition-start="month_now()"
      @update:pages="ref_check()"
      @drag="dragValue = $event"
      @update:modelValue="send_range($event)"
    >
      <template #day-popover="{ format }">
        <div class="text-sm">
          {{ format(dragValue ? dragValue.start : date_pick.start, "MMM D") }}
          -
          {{ format(dragValue ? dragValue.end : date_pick.end, "MMM D") }}
        </div>
      </template>
    </DatePicker>
    <Calendar
      v-else
      :initial-page="{ month: date_now.month, year: date_now.year }"
      :expanded="isExpanded"
      :attributes="attributes"
      ref="date"
      @transition-start="month_now()"
      @update:pages="ref_check()"
    />
  </div>
</template>

<script>
import { Calendar, DatePicker } from "v-calendar";
import { ref } from "vue";
const _ = require("lodash");

export default {
  name: "TransactionCalendar",
  components: {
    Calendar,
    DatePicker,
  },
  data() {
    return {
      date: ref(null),
      date_pick: ref({
        start: new Date(this.date_now.year, this.date_now.month),
        end: new Date(this.date_now.year, this.date_now.month),
      }),
      dragValue: ref(null),
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
    date_now: {
      type: Object,
      default: () => {
        return {
          month: new Date().getMonth() + 1,
          year: new Date().getFullYear(),
        };
      },
    },
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
    isDatepicker: {
      type: Boolean,
      default: () => false,
    },
  },
  computed: {
    selectDragAttribute() {
      return {
        popover: {
          visibility: "hover",
          isInteractive: false,
        },
      };
    },
  },
  methods: {
    send_range(event) {
      this.$emit("send_range", event.start.getDate(), event.end.getDate());
    },
    ref_check() {
      _.find(this.attributes, { key: "deposit" }).dates = this.deposit;
      _.find(this.attributes, { key: "withdrawal" }).dates = this.withdrawal;
    },
    month_now() {
      if (this.isDatepicker) {
        this.$emit(
          "month_year",
          this.$refs.date.calendarRef.pages[0].month,
          this.$refs.date.calendarRef.pages[0].year
        );
      } else {
        this.$emit(
          "month_year",
          this.$refs.date.pages[0].month,
          this.$refs.date.pages[0].year
        );
      }
    },
  },
};
</script>
