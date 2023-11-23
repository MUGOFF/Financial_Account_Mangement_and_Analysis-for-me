<template>
  <div>
    <table>
      <thead>
        <tr>
          <th>
            <input type="checkbox" v-model="masterCheckbox" />
          </th>
          <th>Column 1</th>
          <th>Column 2</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(row, index) in rows" :key="index">
          <td>
            <input type="checkbox" :value="row" v-model="selectedRows" />
          </td>
          <td>{{ row.column1 }}</td>
          <td>{{ row.column2 }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  data() {
    return {
      rows: [
        { column1: "Row 1, Column 1", column2: "Row 1, Column 2" },
        { column1: "Row 2, Column 1", column2: "Row 2, Column 2" },
        { column1: "Row 3, Column 1", column2: "Row 3, Column 2" },
      ],
      selectedRows: [],
    };
  },
  computed: {
    masterCheckbox: {
      get() {
        return this.selectedRows.length === this.rows.length;
      },
      set(value) {
        this.selectedRows = value ? this.rows.slice() : [];
      },
    },
  },
};
</script>
