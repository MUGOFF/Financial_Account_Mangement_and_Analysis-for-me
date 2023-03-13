<template>
  <div>
    <div class="mb-3">
      <label for="file-input" class="form-label">Select file</label>
      <input type="file" id="file-input" @change="onFileChange" />
    </div>

    <div class="table-responsive" v-if="tableON">
      <table class="table table-striped">
        <thead>
          <tr>
            <th v-for="heading in headings" :key="heading">{{ heading }}</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, index) in paginatedRows" :key="index">
            <td v-for="(cell, i) in row" :key="i">{{ cell }}</td>
            <td>
              <input type="checkbox" v-model="checkedRows" :value="index" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div>
      <button class="btn btn-danger" @click="deleteRows">
        Delete Selected Rows
      </button>
    </div>

    <nav aria-label="Page navigation example">
      <ul class="pagination">
        <li class="page-item" :class="{ disabled: currentPage === 1 }">
          <a
            class="page-link"
            href="#"
            aria-label="Previous"
            @click.prevent="previousPage"
          >
            <span aria-hidden="true">&laquo;</span>
          </a>
        </li>
        <li
          class="page-item"
          v-for="pageNumber in pageCount"
          :key="pageNumber"
          :class="{ active: currentPage === pageNumber }"
        >
          <a class="page-link" href="#" @click.prevent="gotoPage(pageNumber)">{{
            pageNumber
          }}</a>
        </li>
        <li class="page-item" :class="{ disabled: currentPage === pageCount }">
          <a
            class="page-link"
            href="#"
            aria-label="Next"
            @click.prevent="nextPage"
          >
            <span aria-hidden="true">&raquo;</span>
          </a>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script>
import * as XLSX from "xlsx/xlsx.mjs";

export default {
  data() {
    return {
      headings: [],
      rows: [],
      tableData: {},
      selectedRows: [],
      tableON: false,
      currentPage: 1,
      rowsPerPage: 10,
    };
  },
  computed: {
    paginatedRows() {
      const start = (this.currentPage - 1) * this.rowsPerPage;
      const end = start + this.rowsPerPage;
      return this.rows.slice(start, end);
    },
    totalPages() {
      return Math.ceil(this.rows.length / this.rowsPerPage);
    },
  },
  methods: {
    onFileChange(event) {
      const file = event.target.files[0];
      const reader = new FileReader();

      reader.onload = (e) => {
        const data = new Uint8Array(e.target.result);
        const workbook = XLSX.read(data, { type: "array" });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];

        const rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
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
    deleteRows() {
      this.selectedRows.forEach((index) => {
        this.rows.splice(index, 1);
      });
      this.selectedRows = [];

      // Update the table data object after deleting the rows
      const tableData = {};
      this.headings.forEach((heading, index) => {
        tableData[heading] = this.rows.map((row) => row[index]);
      });
      this.tableData = tableData;
    },
    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },
  },
};
</script>
