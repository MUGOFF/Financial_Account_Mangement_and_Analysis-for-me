<template>
  <div class="container">
    <div>AccountManagement Page</div>
    <div class="d-flex flex-row-reverse">
      <button
        type="button"
        class="btn m-2 btn-primary"
        data-bs-toggle="modal"
        data-bs-target="#accoutadd"
      >
        계좌 추가
      </button>
      <!-- <button type="button" @click="add_account()">check</button> --><!-- dialog check -->
      <!-- <button type="button" class="btn m-2 btn-secondary" @click="">계좌 수정</button>
      <button type="button" class="btn m-2 btn-danger" @click="">계좌 삭제</button> -->
    </div>
    <p class="text-center bg-light fw-bold fs-3">은행</p>
    <div class="table-responsive">
      <table class="table tableborderd table-sm">
        <thead>
          <tr>
            <th>No</th>
            <th>이름</th>
            <th>은행</th>
            <th>계좌번호</th>
            <th>계좌종류</th>
            <th>비고</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(account, index) in account_table" :key="index">
            <td>{{ index + 1 }}</td>
            <td>{{ account.nickname }}</td>
            <td>{{ account.bankname }}</td>
            <td>{{ account.accountnumber }}</td>
            <td>{{ account.account_type }}</td>
            <td>
              <input
                class="form-check-input"
                type="checkbox"
                value=""
                id="flexCheckDefault"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <p class="text-center bg-light fw-bold fs-3">카드</p>
    <div class="table-responsive">
      <table class="table tableborderd table-sm">
        <thead>
          <tr>
            <th>No</th>
            <th>이름</th>
            <th>카드회사</th>
            <th>카드번호</th>
            <th>카드종류</th>
            <th>연결계좌</th>
            <th>비고</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(account, index) in card_table" :key="index">
            <td>{{ index + 1 }}</td>
            <td>{{ account.nickname }}</td>
            <td>{{ account.corpname }}</td>
            <td>{{ account.cardnumber }}</td>
            <td>{{ account.card_type }}</td>
            <td>{{ account.bankconnect }}</td>
            <td>
              <input
                class="form-check-input"
                type="checkbox"
                value=""
                id="flexCheckDefault"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <p class="text-center bg-light fw-bold fs-3">페이</p>
    <div class="table-responsive">
      <table class="table tableborderd table-sm">
        <thead>
          <tr>
            <th>No</th>
            <th>이름</th>
            <th>페이이름</th>
            <th>연결계좌</th>
            <th>연결카드</th>
            <th>비고</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(account, index) in pay_table" :key="index">
            <td>{{ index + 1 }}</td>
            <td>{{ account.nickname }}</td>
            <td>{{ account.corpname }}</td>
            <td>{{ account.bankconnection }}</td>
            <td>{{ account.cardconnection }}</td>
            <td>{{ account.description }}</td>
            <td>
              <input
                class="form-check-input"
                type="checkbox"
                value=""
                id="flexCheckDefault"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <!-- Modal -->
  <div
    class="modal fade"
    id="accoutadd"
    data-bs-backdrop="static"
    data-bs-keyboard="false"
    tabindex="-1"
    aria-labelledby="accoutaddLabel"
    aria-hidden="true"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="accoutaddLabel">Modal title</h1>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>
        <div class="modal-body">
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

        <form id="ADD_FORM" @submit.prevent="add_account()">
          <div class="modal-body">
            <div class="input-group mb-2">
              <span class="input-group-text">이름</span>
              <input type="text" class="form_control" v-model="name" required />
            </div>
            <div class="input-group mb-2">
              <!-- bank account add -->
              <span class="input-group-text" v-if="fi_type === 'bank'"
                >은행명</span
              >
              <!-- card account add -->
              <span class="input-group-text" v-if="fi_type === 'card'"
                >회사명</span
              >
              <!-- pay account add -->
              <span class="input-group-text" v-if="fi_type === 'pay'"
                >페이명</span
              >
              <input type="text" class="form_control" v-model="corp" required />
            </div>
            <div class="input-group mb-2" v-if="fi_type !== 'pay'">
              <!-- bank account add -->
              <span class="input-group-text" v-if="fi_type === 'bank'"
                >계좌번호</span
              >
              <!-- card account add -->
              <span class="input-group-text" v-if="fi_type === 'card'"
                >카드번호</span
              >
              <input
                type="text"
                class="form_control"
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
              <span class="input-group-text" v-if="fi_type === 'bank'"
                >계좌종류</span
              >
              <!-- card account add -->
              <span class="input-group-text" v-if="fi_type === 'card'"
                >카드종류</span
              >
              <input
                type="text"
                class="form_control"
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
                class="form_control"
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
              <span class="input-group-text">연동 계좌</span>
              <input
                type="text"
                class="form_control"
                list="connected_account"
                v-model="connection"
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
            <div class="input-group mb-2">
              <span class="input-group-text">비고</span>
              <input
                type="textarea"
                class="form_control"
                v-model="description"
              />
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              data-bs-dismiss="modal"
            >
              닫기
            </button>
            <button type="submit" class="btn btn-primary">확인</button>
          </div>
        </form>
      </div>
    </div>
  </div>
  <!-- Modal -->
  <dialog>
    <form method="dialog">
      <div id="dialog_body" class="container text-start">field_text</div>
      <button class="m-2 btn btn-secondary" value="close">닫기</button>
      <button class="m-2 btn btn-info" value="confirm">확인</button>
    </form>
  </dialog>
</template>
<script>
import axios from "axios";
export default {
  name: "AccountManagement",
  data() {
    return {
      account_table: {},
      card_table: {},
      pay_table: {},
      fi_type: "bank",
    };
  },
  computed: {
    account_get: function () {
      var table = this.account_table;
      return table;
    },
  },
  mounted() {
    this.get_table();
  },
  methods: {
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
    add_account() {
      const dialog = document.querySelector("dialog");
      const dialog_field = dialog.querySelector("#dialog_body");
      const account_form = document.getElementById("ADD_FORM");
      const inputlabel =
        account_form.getElementsByClassName("input-group-text");
      const inputvalue = account_form.getElementsByTagName("input");
      var dialog_text = "";
      for (const [key] of Object.entries(inputlabel)) {
        dialog_text = dialog_text + inputlabel[key].innerHTML + " : ";
        dialog_text = dialog_text + inputvalue[key].value + "<br>";
      }
      dialog_text = dialog_text + "<br>위 정보로 계좌를 추가합니다.";
      dialog_field.innerHTML = dialog_text;
      dialog.addEventListener(
        "close",
        () => {
          const value = dialog.returnValue;
          if (value === "confirm") {
            if (this.fi_type === "bank") {
              axios
                .post("api/v1/bank_account/", {
                  nickname: this.name,
                  bankname: this.corp,
                  accountnumber: this.accountnumber,
                  account_type: this.type,
                  description: this.description,
                })
                .then((response) => {
                  console.log(response);
                  alert("Success");
                })
                .catch((error) => {
                  console.error(error);
                });
            } else if (this.fi_type === "card") {
              axios
                .post("api/v1/card_account/", {
                  nickname: this.name,
                  corpname: this.corp,
                  cardnumber: this.accountnumber,
                  card_type: this.type,
                  bankconnect: this.connection,
                  description: this.description,
                })
                .then((response) => {
                  console.log(response);
                  alert("Success");
                })
                .catch((error) => {
                  console.error(error);
                });
            } else {
              // alert("account");
            }
          }
        },
        { once: true }
      );
      dialog.showModal();
    },
  },
};
</script>
<style>
dialog {
  text-align: center;
  border: 0;
  box-shadow: 0 12px 24px gray;
  border-radius: 20px;
}
</style>
