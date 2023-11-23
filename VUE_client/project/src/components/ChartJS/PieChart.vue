<template>
  <Pie :options="chartData.options" :data="chartData.data" />
</template>
<script>
import { Pie } from "vue-chartjs";
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
  LinearScale,
} from "chart.js";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
  LinearScale
);

export default {
  name: "PieChart",
  components: { Pie },
  props: {
    chartData: {
      type: Object,
      required: true,
    },
  },
};
</script>
<style></style>
