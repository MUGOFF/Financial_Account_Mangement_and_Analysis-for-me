<template>
  <BarChart :chartData="chart_data_return()" />
</template>
<script>
import BarChart from "@/components/ChartJS/BarChart.vue";
import axios from "axios";
const _ = require("lodash");

export default {
  name: "BookChart",
  components: { BarChart },
  props: {
    TransactionData: {
      type: Array,
      required: true,
    },
    TransactionData_Previous: {
      type: Object,
    },
    year: { type: Number, required: true },
    month: { type: Number, required: true },
  },
  data() {
    return {
      category_table: [],
    };
  },
  computed: {
    category_comsume() {
      const consume_main = this.category_table
        .filter((category) => category.flow_category === "소비")
        .map((category) => category.main_category);
      return consume_main;
    },
    category_in_flow() {
      return [
        ...new Set(
          this.TransactionData.map((transaction) => transaction.main_category)
        ),
      ];
    },
  },
  mounted() {
    this.get_category();
  },
  methods: {
    get_category() {
      axios.get("api/v1/account_record/Category/").then((response) => {
        this.category_table = response.data;
      });
    },
    chart_data_return() {
      // 항목 설정
      const Consume_Category = this.category_in_flow.filter((category) =>
        this.category_comsume.includes(category)
      );
      let tooltip_data = Consume_Category.map((category) => [
        category,
        this.supplier_counters(category),
      ]);
      let chartdata = {
        data: {
          labels: [],
          datasets: [
            {
              label:
                String(this.year) + "-" + String(this.month).padStart(2, "0"),
              backgroundColor: "#AA1122",
              data: [],
            },
          ],
        },
        options: {
          maintainAspectRatio: false,
          //tooltip plugin start
          plugins: {
            tooltip: {
              callbacks: {
                label: function (context) {
                  let label = context.dataset.label || "";
                  if (label) {
                    label += ": ";
                  }
                  if (context.parsed.y !== null) {
                    label += new Intl.NumberFormat("ko-KR", {
                      style: "currency",
                      currency: "KRW",
                    }).format(context.parsed.y);
                  }
                  let label_return = [label];
                  tooltip_data.forEach((data) => {
                    if (data[0] === context.label) {
                      data[1].forEach((arr) => {
                        let base = "";
                        base += String(arr[0]) + ":" + String(arr[1]);
                        label_return.push(base);
                      });
                    }
                  });
                  return label_return;
                },
              },
            },
          },
          //tooltip plugin end
        },
      };
      let chart_dataset = new Array();
      Consume_Category.forEach((category) => {
        let amount = this.consum_from_main_category(category);
        chart_dataset.push({ label: category, data: amount });
      });
      // 데이터정렬
      let sortedchart_dataset = chart_dataset.sort(function (a, b) {
        return b.data > a.data;
      });
      let top_3_dataset = sortedchart_dataset.slice(0, 3);
      let etc_dataset = sortedchart_dataset.slice(3);
      if (etc_dataset.length > 1) {
        etc_dataset.reduce((a, b) => {
          return { label: "ETC", data: a.data + b.data };
        });
      }
      top_3_dataset.forEach((dataset) => {
        chartdata.data.labels.push(dataset.label);
        chartdata.data.datasets[0].data.push(dataset.data);
      });
      if (etc_dataset.length > 0) {
        chartdata.data.labels.push(etc_dataset.label);
        chartdata.data.datasets[0].data.push(etc_dataset.data);
      }
      return chartdata;
    },
    consum_from_main_category(category) {
      const consume = this.TransactionData.filter(
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
    supplier_counters(category) {
      const category_data = this.TransactionData.filter(
        (transaction) => transaction.main_category === category
      );
      const suplier = category_data.map(
        (transaction) => transaction.transaction_to_name
      );
      const counter = [...new Set(suplier)].map((name) => [
        name,
        suplier.filter((inner_name) => inner_name === name).length,
      ]);
      return counter;
    },
  },
};
</script>
<style></style>
