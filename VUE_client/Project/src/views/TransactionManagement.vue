<template>
  <div class="container">
    <div>h1.TransactionManagement Page</div>
    <ul class="pagination justify-content-center">
      <li>
        <span class="datetext" aria-hidden="true">&laquo;</span>
      </li>
      <li>
        <span class="datetext" aria-hidden="true">&lt;</span>
      </li>
      <li>
        <input
          type="text"
          v-model="yearmonth"
          id="yearmonth"
          class="datetext"
          size="4"
          maxlength="7"
          @click="saveoldvalue(value)"
          @change="changemonth()"
        />
      </li>
      <li>
        <span class="datetext" aria-hidden="true">&gt;</span>
      </li>
      <li>
        <span class="datetext" aria-hidden="true">&raquo;</span>
      </li>
    </ul>
  </div>
</template>
<script>
export default {
  // this.$route.params
  data() {
    return {
      yearmonth:
        new Date().getFullYear() +
        "." +
        String(new Date().getMonth() + 1).padStart(2, "0"),
      yearmonth_old: "",
    };
  },
  computed: {
    force_expression: function () {
      // const datereg = /[0-9]{4}.[0-9]{2}/;
      return 1;
    },
  },
  methods: {
    saveoldvalue(value) {
      this.yearmonth_old = document.getElementById("yearmonth").value;
      console.log(value);
    },
    changemonth() {
      console.log(this.yearmonth_old);
      console.log(this.yearmonth);
    },
  },
};
</script>
<style>
.datetext {
  border: none;
  padding: none;
  text-align: center;
  font-size: 30px;
  margin: 0 20px;
}
</style>
