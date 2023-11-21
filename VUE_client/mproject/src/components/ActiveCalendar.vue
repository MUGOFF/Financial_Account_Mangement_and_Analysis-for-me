<!-- calendar -->
<template>
  <Calendar class="w-100" />
  <DatePicker class="w-100" v-model="date" />
</template>

<script>
import { Calendar, DatePicker } from "v-calendar";
import "v-calendar/style.css";

export default {
  components: {
    Calendar,
    DatePicker,
  },
  data() {
    return {
      date: new Date(),
    };
  },
};
</script>
