<template>
  <div class="w-75 container-fluid">
    <div class="d-flex">
      <div class="container-lg">
        <div class="d-flex">
          <div class="input-group m-3">
            <span class="input-group-text">은행선택</span>
            <select class="form-select" required>
              <option
                v-for="account in account_table"
                :key="account"
                :value="account.accountnumber"
              >
                {{ account.nickname }}
              </option>
            </select>
          </div>
          <div class="input-group m-3">
            <span class="input-group-text">카드선택</span>
            <select class="form-select">
              <option value="" selected>----------</option>
              <option
                v-for="card in card_table"
                :key="card"
                :value="card.cardnumber"
              >
                {{ card.nickname }}
              </option>
            </select>
          </div>
          <div class="input-group m-3">
            <input
              type="file"
              id="table_file_upload"
              class="invisible"
              accept=".xlsx,.xls"
              @change="onFileChange"
            />
          </div>
          <div class="input-group m-3">
            <span class="input-group-text">행 표시수</span>
            <select class="form-select rounded" v-model="rowsPerPage">
              <option value="10" selected>10개</option>
              <option value="30">30개</option>
              <option value="50">50개</option>
            </select>
          </div>
        </div>
        <div class="container-fluid main-component">
          <!-- file drop zone -->
          <div
            v-if="!tableON"
            class="d-flex drop-file-zone justify-content-evenly align-items-center px-3"
            @drop="dragfile"
            @dragover.prevent
          >
            <img :src="require('@/assets/file_upload_icon.png')" />
            <h1 class="display-2 text-primary">OR</h1>
            <label for="table_file_upload" class="btn btn-success btn-lg"
              >파일 업로드</label
            >
          </div>
          <!-- table div -->
          <div v-if="tableON" class="table-responsive">
            <table class="table table-bordered">
              <thead>
                <tr>
                  <th v-for="heading in headings" :key="heading">
                    {{ heading }}
                  </th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(prow, index) in paginatedRows" :key="index">
                  <td v-for="(cell, i) in prow" :key="i">{{ cell }}</td>
                  <td>
                    <input
                      type="checkbox"
                      class="form-check-input"
                      :value="{ 0: paginatedRows[index], 1: index }"
                      v-model="selectedRows"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <!-- page numbers -->
          <div v-if="tableON" class="text-center">
            <ul class="pagination justify-content-center">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <a
                  class="page-link"
                  href="#"
                  aria-label="Previous"
                  @click.prevent="Previous()"
                >
                  <span aria-hidden="true">&laquo;</span>
                </a>
              </li>
              <li class="page-item" v-if="currentPage > 3">
                <a class="page-link" href="#" @click.prevent="showPage(1)">
                  1</a
                >
              </li>
              <li class="page-item" v-if="currentPage > 3">
                <span class="page-link" href="#"> ...</span>
              </li>
              <li class="page-item" v-for="index in pageRows" :key="index">
                <a class="page-link" href="#" @click.prevent="showPage(index)">
                  {{ index }}</a
                >
              </li>
              <li class="page-item" v-if="currentPage < totalPages - 2">
                <span class="page-link"> ...</span>
              </li>
              <li class="page-item" v-if="currentPage < totalPages - 2">
                <a
                  class="page-link"
                  href="#"
                  @click.prevent="showPage(totalPages)"
                >
                  {{ totalPages }}</a
                >
              </li>
              <li
                class="page-item"
                :class="{ disabled: currentPage === totalPages }"
              >
                <a
                  class="page-link"
                  href="#"
                  aria-label="Next"
                  @click.prevent="Next()"
                >
                  <span aria-hidden="true">&raquo;</span>
                </a>
              </li>
            </ul>
          </div>
        </div>
        <!-- d-block -->
      </div>
      <div class="card mt-3" style="width: 20vw; height: 40vh">
        <!-- v-if="selectedRows.length > 0"-->
        <div class="card-body text-align-center">
          <div class="btn-group w-100">
            <button class="w-50 btn btn-outline-danger" @click="deleteRow()">
              행 삭제
            </button>
            <button
              type="button"
              class="w-50 btn btn-outline-success"
              @click="submitform"
            >
              표 입력
            </button>
          </div>
          <div class="btn-group w-100">
            <button
              class="w-50 btn btn-outline-secondary"
              @click="changeHeading()"
            >
              헤더 변경
            </button>
            <button
              class="w-50 btn btn-outline-primary"
              @click="transform_table()"
            >
              표 변경
            </button>
          </div>
        </div>
        <!-- card -->
      </div>
      <!-- d-flex -->
    </div>
    <!-- container -->
  </div>
  <!-- Modal -->
  <dialog>
    <form method="dialog">
      <div id="dialog_body" class="container text-start">field_text</div>
      <button class="m-2 btn btn-secondary" value="close">취소</button>
      <button class="m-2 btn btn-info" data-bs-dismiss="modal" value="confirm">
        확인
      </button>
    </form>
  </dialog>
</template>

<script>
import * as XLSX from "xlsx";
// import * as XLSX from "xlsx/xlsx.mjs";
import axios from "axios";
const _ = require("lodash");

export default {
  name: "AddTable",
  data() {
    return {
      account_table: {},
      card_table: {},
      pay_table: {},
      headings: [],
      rows: [],
      selectedRows: [],
      tableData: {},
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
    pageRows() {
      let pagerow = _.range(this.currentPage - 2, this.currentPage + 3);
      pagerow = _.filter(pagerow, (page) => page > 0);
      pagerow = _.filter(pagerow, (page) => page <= this.totalPages);
      return pagerow;
    },
    totalPages() {
      return Math.ceil(this.rows.length / this.rowsPerPage);
    },
  },
  mounted() {
    this.get_table();
  },
  methods: {
    dragfile(event) {
      event.preventDefault();
      alert("drop");
    },
    onFileChange(event) {
      const file = event.target.files[0];
      const reader = new FileReader();
      reader.onload = (event) => {
        const data = new Uint8Array(event.target.result);
        const workbook = XLSX.read(data, { type: "array" });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
        this.headings = rows.shift();
        this.rows = rows;
        // Create an object with the table data organized by column
        // const tableData = {};
        // this.headings.forEach((heading, index) => {
        //   tableData[heading] = this.rows.map((row) => row[index]);
        // });
        const maxlenrow = Math.max(...rows.map((row) => row.length));
        this.headings = this.headings.map(
          (heading, index) => heading + ":" + (index + 1)
        );
        this.headings = this.headings.concat(
          _.range(this.headings.length + 1, maxlenrow + 1)
        );
        this.rows = this.rows.map((row) =>
          row.concat(_.range(row.length + 1, maxlenrow + 1))
        );
        this.tableON = true;
      };
      reader.readAsArrayBuffer(file);
    },
    deleteRow() {
      this.selectedRows.map((obj) => {
        _.pull(this.rows, obj[0]);
      });
      this.selectedRows = [];
      // Update the table data object after deleting the row
      // const tableData = {};
      // this.headings.forEach((heading, index) => {
      //   tableData[heading] = this.rows.map((row) => row[index]);
      // });
      // this.tableData = tableData;
    },
    changeHeading() {
      if (this.selectedRows.length === 0) {
        alert("선택된 행이 없습니다.");
        return false;
      }
      this.selectedRows.sort();
      const maxrow = Math.max(...this.selectedRows.map((row) => row[1]));
      let changerow = [];
      if (this.selectedRows.length > 1) {
        this.selectedRows.forEach((obj) => {
          changerow = changerow.concat(obj[0]);
        });
        this.headings = changerow;
        this.rows.splice(0, maxrow + 1);
        this.rows = this.rows.map((row, index, array) => {
          if (index % this.selectedRows.length === 0) {
            row = row.concat(array[index + 1], array[index + 2]);
            return row;
          }
        });
        this.rows = _.without(this.rows, undefined);
      } else {
        this.headings = this.rows[this.selectedRows[0][1]];
        this.rows.splice(this.selectedRows[0][1], 1);
      }
      this.selectedRows = [];
    },
    transform_table() {
      const tableData = {};
      this.rows.forEach((row) => {
        const rowobj = new Object();
        this.headings.map((heading, index) => {
          rowobj[heading] = row[index];
        });
        tableData.push(rowobj);
      });
      console.log(tableData);
    },
    get_table() {
      axios
        .get("api/v1/bank_account/")
        .then((response) => {
          this.account_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      axios
        .get("api/v1/card_account/")
        .then((response) => {
          this.card_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      axios
        .get("api/v1/pay_account/")
        .then((response) => {
          this.pay_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
    },
    showPage(index) {
      this.currentPage = index;
    },
    Previous() {
      this.currentPage--;
    },
    Next() {
      this.currentPage++;
    },
  },
};
</script>

<style>
.main-component {
  width: 60vw;
  height: 60vh;
  /* box-shadow: 2px 5px 5px gray; */
}
.drop-file-zone {
  border: dashed skyblue;
  border-radius: 24px;
  height: 60vh;
}
</style>
