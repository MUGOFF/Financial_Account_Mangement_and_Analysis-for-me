<template>
  <div class="w-75 container-fluid">
    <div class="d-flex">
      <div class="container-lg">
        <div class="d-flex">
          <div class="input-group m-3">
            <span class="input-group-text">은행선택</span>
            <select class="form-select" v-model="form.bank" required>
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
            <select class="form-select" v-model="form.card">
              <option :value="null" selected>----------</option>
              <option
                v-for="card in card_table"
                :key="card"
                :value="card.cardnumber"
              >
                {{ card.nickname }}
              </option>
              <!-- <option disabled>____________</option> -->
              <!-- <option value="pay">페이로 변경</option> -->
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
              <option :value="10" selected>10개</option>
              <option :value="30">30개</option>
              <option :value="50">50개</option>
              <option :value="100">100개</option>
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
                  <th
                    v-for="heading in tableData.headings"
                    :key="heading"
                    @click="sortBy(heading)"
                  >
                    {{ heading }}
                  </th>
                  <th>
                    <input
                      type="checkbox"
                      class="form-check-input"
                      v-model="MasterCheckbox"
                    />
                  </th>
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
              <li
                class="page-item"
                v-if="currentPage > 3"
                :class="{ active: currentPage === 1 }"
              >
                <a class="page-link" href="#" @click.prevent="showPage(1)">
                  1</a
                >
              </li>
              <li class="page-item" v-if="currentPage > 3">
                <span class="page-link" href="#"> ...</span>
              </li>
              <li
                class="page-item"
                v-for="index in pageRows"
                :key="index"
                :class="{ active: currentPage === index }"
              >
                <a class="page-link" href="#" @click.prevent="showPage(index)">
                  {{ index }}</a
                >
              </li>
              <li class="page-item" v-if="currentPage < totalPages - 2">
                <span class="page-link"> ...</span>
              </li>
              <li
                class="page-item"
                v-if="currentPage < totalPages - 2"
                :class="{ active: currentPage === totalPages }"
              >
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
              @click="openmodal()"
            >
              표 입력
            </button>
          </div>
          <div class="btn-group w-100">
            <button
              class="w-50 btn btn-outline-secondary"
              @click="transform_table()"
            >
              표(머리) 변경
            </button>
            <button class="w-50 btn btn-outline-primary" @click="reset_table()">
              초기화
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
      <div id="dialog_body" class="container text-start">
        <div class="input-group m-2">
          <span class="input-group-text">거래시각</span>
          <select v-model="form.time" class="form-select">
            <option
              v-for="heading in tableData.headings"
              :key="heading"
              :value="heading"
            >
              {{ heading }}
            </option>
          </select>
          <!-- <span class="input-group-text">날짜형식</span>
          <input v-model="form.format" class="form-control" /> -->
        </div>
        <div class="input-group m-2">
          <span class="input-group-text">계좌이름</span>
          <input v-model="form.bank" class="form-control" readonly />
        </div>
        <div class="input-group m-2">
          <span class="input-group-text">카드이름</span>
          <input v-model="form.card" class="form-control" readonly />
          <!-- list="cards_list" -->
          <!-- <datalist id="cards_list">
            <option value="입출금계좌"></option>
            <option value="정기예금계좌"></option>
            <option value="정기적금계좌"></option>
            <option value="예탁금"></option>
          </datalist> -->
        </div>
        <div class="input-group m-2">
          <span class="input-group-text">거래처회사이름</span>
          <select v-model="form.corp" class="form-select">
            <option
              v-for="heading in tableData.headings"
              :key="heading"
              :value="heading"
            >
              {{ heading }}
            </option>
          </select>
        </div>
        <div class="input-group m-2">
          <span class="input-group-text">입금금액</span>
          <select v-model="form.deposit" class="form-select">
            <option
              v-for="heading in tableData.headings"
              :key="heading"
              :value="heading"
            >
              {{ heading }}
            </option>
          </select>
        </div>
        <div class="input-group m-2">
          <span class="input-group-text">출금금액</span>
          <select v-model="form.withdrawal" class="form-select">
            <option
              v-for="heading in tableData.headings"
              :key="heading"
              :value="heading"
            >
              {{ heading }}
            </option>
          </select>
        </div>
        <div class="input-group m-2">
          <span class="input-group-text">비고내용</span>
          <select v-model="form.desc" class="form-select">
            <option
              v-for="heading in tableData.headings"
              :key="heading"
              :value="heading"
            >
              {{ heading }}
            </option>
          </select>
        </div>
      </div>
      <button class="m-2 btn btn-secondary" value="close">취소</button>
      <button class="m-2 btn btn-info" value="confirm">확인</button>
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
      selectedRows: [],
      tableData: {
        headings: [],
        rows: [],
      },
      form: {
        time: "",
        // format: "YYYY-mm-DDTHH:MM:SS",
        bank: "",
        card: null,
        corp: "",
        deposit: "입금금액",
        withdrawal: "출금금액",
        desc: "",
      },
      tableON: false,
      sortColumn: "",
      sortDirection: 1,
      sortStart: false,
      currentPage: 1,
      rowsPerPage: 10,
    };
  },
  computed: {
    sortedRows() {
      const sorted = [...this.tableData.rows];
      sorted.sort((a, b) => {
        if (a[this.sortColumn] < b[this.sortColumn])
          return -1 * this.sortDirection;
        if (a[this.sortColumn] > b[this.sortColumn])
          return 1 * this.sortDirection;
        return 0;
      });
      return sorted;
    },
    paginatedRows() {
      const start = (this.currentPage - 1) * this.rowsPerPage;
      const end = start + this.rowsPerPage;
      if (this.sortStart) {
        return this.sortedRows.slice(start, end);
      } else {
        return this.tableData.rows.slice(start, end);
      }
    },
    pageRows() {
      let pagerow = _.range(this.currentPage - 2, this.currentPage + 3);
      pagerow = _.filter(pagerow, (page) => page > 0);
      pagerow = _.filter(pagerow, (page) => page <= this.totalPages);
      return pagerow;
    },
    totalPages() {
      return Math.ceil(this.tableData.rows.length / this.rowsPerPage);
    },
    MasterCheckbox: {
      get() {
        return this.selectedRows.length === this.rowsPerPage;
      },
      set(value) {
        this.selectedRows = value
          ? this.paginatedRows.map((row, index) => {
              return { 0: row, 1: index };
            })
          : [];
      },
    },
  },
  mounted() {
    this.get_table();
  },
  methods: {
    dragfile(event) {
      event.preventDefault();
      const file = event.dataTransfer.files[0];
      const reader = new FileReader();
      reader.onload = (event) => {
        const data = new Uint8Array(event.target.result);
        const workbook = XLSX.read(data, { type: "array" });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        let rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
        this.tableData.headings = rows.shift();
        // Create an object with the table data organized by column
        // const tableData = {};
        // this.headings.forEach((heading, index) => {
        //   tableData[heading] = this.rows.map((row) => row[index]);
        // });
        const maxlenrow = Math.max(...rows.map((row) => row.length));
        this.tableData.headings = this.tableData.headings.map(
          (heading, index) => heading + ":" + (index + 1)
        );
        this.tableData.headings = this.tableData.headings.concat(
          _.range(this.tableData.headings.length + 1, maxlenrow + 1)
        );
        rows = rows.map((row) =>
          row.concat(_.range(row.length + 1, maxlenrow + 1))
        );
        this.tableON = true;
        this.sortColumn = this.tableData.headings[0];
        rows.forEach((row) => {
          const rowobj = new Object();
          this.tableData.headings.forEach((heading, index) => {
            rowobj[heading] = row[index];
          });
          this.tableData.rows.push(rowobj);
        });
      };
      reader.readAsArrayBuffer(file);
    },
    onFileChange(event) {
      const file = event.target.files[0];
      const reader = new FileReader();
      reader.onload = (event) => {
        const data = new Uint8Array(event.target.result);
        const workbook = XLSX.read(data, { type: "array" });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        let rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
        this.tableData.headings = rows.shift();
        // Create an object with the table data organized by column
        // const tableData = {};
        // this.headings.forEach((heading, index) => {
        //   tableData[heading] = this.rows.map((row) => row[index]);
        // });
        const maxlenrow = Math.max(...rows.map((row) => row.length));
        this.tableData.headings = this.tableData.headings.map(
          (heading, index) => heading + ":" + (index + 1)
        );
        this.tableData.headings = this.tableData.headings.concat(
          _.range(this.tableData.headings.length + 1, maxlenrow + 1)
        );
        rows = rows.map((row) =>
          row.concat(_.range(row.length + 1, maxlenrow + 1))
        );
        this.tableON = true;
        this.sortColumn = this.tableData.headings[0];
        rows.forEach((row) => {
          const rowobj = new Object();
          this.tableData.headings.forEach((heading, index) => {
            rowobj[heading] = row[index];
          });
          this.tableData.rows.push(rowobj);
        });
      };
      reader.readAsArrayBuffer(file);
    },
    deleteRow() {
      this.selectedRows.map((obj) => {
        _.pull(this.tableData.rows, obj[0]);
      });
      this.selectedRows = [];
      if (this.currentPage > this.totalPages) {
        this.Previous();
      }
      // Update the table data object after deleting the row
      // const tableData = {};
      // this.headings.forEach((heading, index) => {
      //   tableData[heading] = this.rows.map((row) => row[index]);
      // });
      // this.tableData = tableData;
    },
    submitform() {
      const regdate = /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}/;
      let forms = this.selectedRows.map((item) => {
        const regexp = /\d+/g;
        const form = new FormData();
        const regarr = Array.from(
          item[0][this.form.time].matchAll(regexp),
          (m) => m[0]
        );
        let timeformat = "";
        regarr.forEach((match, index) => {
          if (0 < index && index < 3) {
            timeformat = timeformat + "-";
          } else if (6 > index && index > 3) {
            timeformat = timeformat + ":";
          } else if (index === 3) {
            timeformat = timeformat + "T";
          }
          timeformat = timeformat + match;
        });
        form.append("transaction_time", timeformat);
        form.append("transaction_from", this.form.bank);
        if (this.form.card !== null) {
          form.append("transaction_from_card", this.form.card);
        }
        form.append("transaction_to_name", item[0][this.form.corp].trim());
        form.append("deposit_amount", item[0][this.form.deposit]);
        form.append("withdrawal_amount", item[0][this.form.withdrawal]);
        form.append("description", item[0][this.form.desc]);
        return form;
      });
      if (!regdate.test(forms[0].get("transaction_time"))) {
        alert("시간 표현이 올바르지 않습니다");
        return false;
      }
      axios
        .all(
          forms.map((form) =>
            axios.post(
              "api/v1/account_transaction/" + this.form.bank + "/",
              form,
              {
                headers: {
                  "Content-Type": "multipart/form-data",
                },
              }
            )
          )
        )
        .then(alert("입력되었습니다"))
        .catch((error) => {
          console.log(error);
        });
      this.deleteRow();
    },
    openmodal() {
      if (!this.tableON) {
        alert("표를 업로드 하세요");
        return false;
      }
      if (this.selectedRows.length === 0) {
        alert("행을 선택하세요");
        return false;
      }
      if (this.form.bank === "") {
        alert("계좌가 설정되지 않았습니다.");
        return false;
      }
      const dialog = document.querySelector("dialog");
      dialog.addEventListener(
        "close",
        () => {
          const value = dialog.returnValue;
          if (value === "confirm") {
            const final_value = confirm("설정한 값들로 입력합니까?");
            if (final_value === true) {
              this.submitform();
            } else {
              this.openmodal();
            }
          }
        },
        { once: true }
      );
      dialog.showModal();
    },
    transform_table() {
      if (this.selectedRows.length === 0) {
        alert("선택된 행이 없습니다.");
        return false;
      }
      this.selectedRows.sort();
      const maxrow = Math.max(...this.selectedRows.map((row) => row[1]));
      let changerow = [];
      if (this.selectedRows.length > 1) {
        this.selectedRows.forEach((obj) => {
          changerow = changerow.concat(Object.values(obj[0]));
        });
        this.tableData.headings = changerow;
        this.sortColumn = this.tableData.headings[0];
        this.tableData.rows.splice(0, maxrow + 1);
        let newrows = this.tableData.rows.map((row, index, array) => {
          if (index % this.selectedRows.length === 0) {
            return Object.values(row).concat(
              Object.values(array[index + 1]),
              Object.values(array[index + 2])
            );
          }
        });
        newrows = _.without(newrows, undefined);
        this.tableData.rows = newrows.map((row) => {
          const rowobj = new Object();
          this.tableData.headings.forEach((heading, index) => {
            rowobj[heading] = row[index];
          });
          return rowobj;
        });
      } else {
        const newheadings = Object.values(
          this.tableData.rows[this.selectedRows[0][1]]
        );
        this.tableData.rows = this.tableData.rows.map((row) => {
          const rowobj = new Object();
          this.tableData.headings.map((heading, index) => {
            rowobj[newheadings[index]] = row[heading];
          });
          return rowobj;
        });
        this.tableData.headings = newheadings;
        this.tableData.rows.splice(this.selectedRows[0][1], 1);
        this.sortColumn = this.tableData.headings[0];
      }
      this.selectedRows = [];
    },
    reset_table() {
      this.tableON = false;
      this.sortStart = false;
      this.tableData.headings = [];
      this.tableData.rows = [];
      this.currentPage = 1;
      this.rowsPerPage = 10;
      document.getElementById("table_file_upload").value = "";
    },
    get_table() {
      axios
        .get("api/v1/account_management/bank_account/")
        .then((response) => {
          this.account_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      axios
        .get("api/v1/account_management/card_account/")
        .then((response) => {
          this.card_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
      axios
        .get("api/v1/account_management/pay_account/")
        .then((response) => {
          this.pay_table = response.data;
        })
        .catch((error) => {
          console.error(error);
        });
    },
    sortBy(column) {
      this.sortStart = true;
      if (column === this.sortColumn) {
        this.sortDirection *= -1;
      } else {
        this.sortColumn = column;
        this.sortDirection = 1;
      }
    },
    showPage(index) {
      this.currentPage = index;
      this.selectedRows = [];
    },
    Previous() {
      this.currentPage--;
      this.selectedRows = [];
    },
    Next() {
      this.currentPage++;
      this.selectedRows = [];
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
