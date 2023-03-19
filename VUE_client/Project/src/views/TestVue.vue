<template>
  <div>
    <!-- <div class="mb-3">
      <label for="file-input" class="form-label">Select file</label>
      <input type="file" id="file-input" @change="onFileChange" />
    </div> -->
    <div class="mb-3">
      <form id="test_FORM" @submit.prevent="test_method()">
        <div class="input-group">
          <input type="text" class="form-control" v-model="test1" />
          <input type="text" class="form-control" v-model="test2" />
        </div>
        <button type="submit" class="btn btn-primary">form sub</button>
      </form>
      <input
        type="radio"
        name="base_type"
        id="bank"
        class="form-check-input"
        value="bank"
        v-model="fi_type"
      />
      <label class="form-check-label mx-1" for="bank"> 은행·증권 </label>
      <input
        type="radio"
        name="base_type"
        id="card"
        class="form-check-input"
        value="card"
        v-model="fi_type"
      />
      <label class="form-check-label mx-1" for="card"> 카드 </label>
      <input
        type="radio"
        name="base_type"
        id="pay"
        class="form-check-input"
        value="pay"
        v-model="fi_type"
      />
      <label class="form-check-label mx-1" for="pay"> 페이 </label>
    </div>
    <div class="container">
      <form id="ADD_FORM" @submit.prevent="test_method()">
        <div class="input-group mb-2">
          <label class="form-label mx-2">이름 </label>
          <input type="text" class="form-control" v-model="name" required />
        </div>
        <div class="input-group mb-2">
          <!-- bank account add -->
          <label class="form-label mx-2" v-if="fi_type === 'bank'"
            >은행명
          </label>
          <!-- card account add -->
          <label class="form-label mx-2" v-if="fi_type === 'card'"
            >회사명
          </label>
          <!-- pay account add -->
          <label class="form-label mx-2" v-if="fi_type === 'pay'">페이명</label>
          <input type="text" class="form-control" v-model="corp" required />
        </div>
        <div class="input-group mb-2" v-if="fi_type !== 'pay'">
          <!-- bank account add -->
          <label class="form-label mx-2" v-if="fi_type === 'bank'"
            >계좌번호</label
          >
          <!-- card account add -->
          <label class="form-label mx-2" v-if="fi_type === 'card'"
            >카드번호</label
          >
          <input
            type="text"
            class="form-control"
            pattern="^[0-9]*$"
            size="20"
            maxlength="20"
            v-model="accountnumber"
            placeholder="'-' 제외"
            required
          />
        </div>
        <div class="input-group mb-2" v-if="fi_type !== 'pay'">
          <!-- bank account add -->
          <label class="form-label mx-2" v-if="fi_type === 'bank'"
            >계좌종류</label
          >
          <!-- card account add -->
          <label class="form-label mx-2" v-if="fi_type === 'card'"
            >카드종류</label
          >
          <input
            type="text"
            class="form-control"
            list="account_type"
            v-model="type"
            v-if="fi_type === 'bank'"
            required
          />
          <datalist id="account_type">
            <option value="입출금계좌"></option>
            <option value="정기예금계좌"></option>
            <option value="정기적금계좌"></option>
            <option value="예탁금"></option>
          </datalist>
          <input
            type="text"
            class="form-control"
            list="card_type"
            v-model="type"
            v-if="fi_type === 'card'"
            required
          />
          <datalist id="card_type">
            <option value="체크카드"></option>
            <option value="신용카드"></option>
            <option value="선불카드"></option>
          </datalist>
        </div>
        <div v-if="fi_type === 'card'" class="input-group mb-2">
          <label class="form-label mx-2">연동 계좌 </label>
          <input
            type="text"
            class="form-control"
            list="connected_account"
            v-model="connection"
            size="6"
            required
          />
          <datalist id="connected_account">
            <option
              v-for="account in account_table"
              :key="account"
              :value="account.accountnumber"
            >
              {{ account.nickname }}
            </option>
          </datalist>
        </div>
        <div v-if="fi_type === 'card'" class="input-group mb-2">
          <label class="form-label mx-2">카드 만기 </label>
          <input
            type="text"
            class="form-control"
            list="expiredmonth"
            v-model="expiredmonth"
            required
          />
          <datalist id="expiredmonth">
            <option
              v-for="month in d_month"
              :key="month"
              :value="month"
            ></option>
          </datalist>
          <span class="input-group-text">월</span>
          <input
            type="text"
            class="form-control"
            v-model="expiredyear"
            required
          />
          <span class="input-group-text">년</span>
        </div>
        <div v-if="fi_type === 'pay'" class="input-group mb-2">
          <label class="form-label mx-2">연동 계좌 </label>
          <input
            type="text"
            class="form-control"
            data-bs-toggle="dropdown"
            aria-expanded="false"
            v-model="connect_account_cheking"
            readonly
          />
          <!-- <button
                  class="dropdown-toggle"
                  type="button"
                  data-bs-toggle="dropdown"
                  aria-expanded="false"
                ></button> -->
          <ul class="dropdown-menu">
            <li
              class="dropdown-item"
              v-for="(account, index) in account_table"
              :key="index"
            >
              <div class="form-check">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="connection_bank"
                  :value="account.accountnumber"
                />
                <label class="form-check-label">
                  {{ account.nickname }}
                </label>
              </div>
            </li>
          </ul>
        </div>
        <div v-if="fi_type === 'pay'" class="input-group mb-2">
          <label class="form-label mx-2">연동 카드 </label>
          <input
            type="text"
            class="form-control"
            data-bs-toggle="dropdown"
            aria-expanded="false"
            v-model="connect_card_cheking"
            readonly
          />
          <ul class="dropdown-menu">
            <li
              class="dropdown-item"
              v-for="(card, index) in card_table"
              :key="index"
            >
              <div class="form-check dropdown-item">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="connection_card"
                  :value="card.cardnumber"
                />
                <label class="form-check-label">
                  {{ card.nickname }}
                </label>
              </div>
            </li>
          </ul>
        </div>
        <div class="input-group mb-2">
          <label class="form-label mx-2">비고 </label>
          <textarea
            type="text"
            rows="4"
            cols="20"
            class="form-control"
            v-model="description"
          />
        </div>

        <!-- <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
          닫기
        </button> -->
        <button type="submit" class="btn btn-primary">확인</button>
      </form>
    </div>
    <!-- <div class="table-responsive" v-if="tableON">
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
    </div> -->

    <!-- <div>
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
    </nav> -->
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
      fi_type: "bank",
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
    test_method() {
      // console.log(1);
      console.log(this.test1);
      console.log(typeof this.test1);
      console.log(this.test2);
      let datetext = new Date(this.test1, this.test2, 1);
      console.log(datetext);
    },
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
