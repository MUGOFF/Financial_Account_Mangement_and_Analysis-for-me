<template>
  <div class="container">
    <input type="file" @change="onFileChange" />
    <div class="table-responsive" style="height: 50vh">
      <table class="table table-bordered">
        <thead>
          <tr v-if="tableON">
            <th v-for="heading in headings" :key="heading">{{ heading }}</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, index) in rows" :key="index">
            <td v-for="(cell, i) in row" :key="i">{{ cell }}</td>
            <td>
              <button class="btn btn-danger" @click="deleteRow(index)">
                Delete
              </button>
              <button
                v-if="headerChange"
                class="btn btn-danger"
                @click="changeHeading(index)"
              >
                표머리
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div>
      <button type="button" class="btn btn-secondary" @click="reset">
        초기화
      </button>
      <button type="button" class="btn btn-success" @click="submitform">
        입력
      </button>
    </div>
  </div>
</template>

<script>
// import * as XLSX from "xlsx";
import * as XLSX from "xlsx/xlsx.mjs";
// import axios from "axios";

export default {
  name: "AddTable",
  data() {
    return {
      headings: [],
      rows: [],
      tableData: {},
      tableON: false,
      headerChange: false,
    };
  },
  methods: {
    onFileChange(event) {
      const file = event.target.files[0];
      const reader = new FileReader();
      reader.onload = (event) => {
        const data = new Uint8Array(event.target.result);
        const workbook = XLSX.read(data, { type: "array" });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
        console.log(rows.shift());
        this.headings = rows.shift();
        this.rows = rows;
        // Create an object with the table data organized by column
        const tableData = {};
        this.headings.forEach((heading, index) => {
          tableData[heading] = this.rows.map((row) => row[index]);
        });
        this.tableData = tableData;
        this.tableON = true;
      };
      reader.readAsArrayBuffer(file);
    },
    deleteRow(index) {
      this.rows.splice(index, 1);

      // Update the table data object after deleting the row
      const tableData = {};
      this.headings.forEach((heading, index) => {
        tableData[heading] = this.rows.map((row) => row[index]);
      });
      this.tableData = tableData;
    },
    changeHeading(index) {
      this.headings = this.rows[index].map((row) => row);
      this.deleteRow(index);
    },
  },
};
</script>

<style>
.container {
  height: 50%;
}
</style>
