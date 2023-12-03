<template>
  <div class="w-75">
    <div class="container">
      <div>AccountManagement Page</div>
      <div class="d-flex flex-row-reverse">
        <button
          type="button"
          class="btn m-2 btn-danger"
          @click="delete_account"
        >
          계좌 삭제
        </button>
        <button
          type="button"
          class="btn m-2 btn-primary"
          data-bs-toggle="modal"
          data-bs-target="#accoutadd"
        >
          계좌 추가
        </button>
        <!-- <button type="button" class="btn m-2 btn-secondary" @click="">계좌 수정</button> -->
      </div>
      <p
        class="text-center bg-light fw-bold fs-3"
        data-bs-toggle="collapse"
        data-bs-target="#banktable"
        aria-expanded="true"
        aria-controls="banktable"
      >
        은행
      </p>
      <div class="table-responsive collapse show" id="banktable">
        <table class="table tableborderd table-hover table-sm">
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
              <td>
                {{ account.accountnumber }}
                <i
                  class="fa-regular fa-copy fa-xs"
                  @click="copy_number(account.accountnumber)"
                ></i>
              </td>
              <td>{{ account.account_type }}</td>
              <td>
                <input
                  class="form-check-input"
                  type="checkbox"
                  :value="{ 0: account.id, 1: 'bank' }"
                  v-model="delete_candidate"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p
        class="text-center bg-light fw-bold fs-3"
        data-bs-toggle="collapse"
        data-bs-target="#cardtable"
        aria-expanded="true"
        aria-controls="cardtable"
      >
        카드
      </p>
      <div class="table-responsive collapse show" id="cardtable">
        <table class="table tableborderd table-hover table-sm">
          <thead>
            <tr>
              <th>No</th>
              <th>이름</th>
              <th>카드회사</th>
              <th>카드번호</th>
              <th>카드종류</th>
              <th>카드만기</th>
              <th>연결계좌</th>
              <th>비고</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(account, index) in card_table" :key="index">
              <td>{{ index + 1 }}</td>
              <td>{{ account.nickname }}</td>
              <td>{{ account.corpname }}</td>
              <td>
                {{ account.cardnumber
                }}<i
                  class="fa-regular fa-copy fa-xs"
                  @click="copy_number(account.cardnumber)"
                ></i>
              </td>
              <td>{{ account.card_type }}</td>
              <td>{{ account.expiredmonth }}</td>
              <td>{{ account.bankconnect }}</td>
              <td>
                <input
                  class="form-check-input"
                  type="checkbox"
                  :value="{ 0: account.id, 1: 'card' }"
                  v-model="delete_candidate"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p
        class="text-center bg-light fw-bold fs-3"
        data-bs-toggle="collapse"
        data-bs-target="#paytable"
        aria-expanded="true"
        aria-controls="paytable"
      >
        페이
      </p>
      <div class="table-responsive collapse show" id="paytable">
        <table class="table tableborderd table-hover table-sm">
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
              <td>
                <input
                  class="form-check-input"
                  type="checkbox"
                  :value="{ 0: account.id, 1: 'pay' }"
                  v-model="delete_candidate"
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
            <label class="form-check-label mx-1" for="bank">은행·증권</label>
            <input
              type="radio"
              name="base_type"
              id="card"
              class="form-check-input"
              value="card"
              v-model="fi_type"
            />
            <label class="form-check-label mx-1" for="card">카드</label>
            <input
              type="radio"
              name="base_type"
              id="pay"
              class="form-check-input"
              value="pay"
              v-model="fi_type"
            />
            <label class="form-check-label mx-1" for="pay">페이</label>
          </div>

          <form id="ADD_FORM" @submit.prevent="add_account()">
            <div class="modal-body">
              <div class="input-group mb-2">
                <label class="form-label mx-2">이름</label>
                <input
                  type="text"
                  class="form-control"
                  v-model="account_form.name"
                  required
                />
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
                <label class="form-label mx-2" v-if="fi_type === 'pay'"
                  >페이명</label
                >
                <input
                  type="text"
                  class="form-control"
                  v-model="account_form.corp"
                  required
                />
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
                  v-model="account_form.accountnumber"
                  placeholder="'-' 제외 숫자만"
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
                  v-model="account_form.type"
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
                  v-model="account_form.type"
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
                <label class="form-label mx-2">연동 계좌</label>
                <input
                  type="text"
                  class="form-control"
                  list="connected_account"
                  v-model="account_form.connection"
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
                <label class="form-label mx-2">카드 만기</label>
                <input
                  type="text"
                  class="form-control"
                  list="expiredmonth"
                  v-model="account_form.expiredmonth"
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
                  v-model="account_form.expiredyear"
                  required
                />
                <span class="input-group-text">년</span>
              </div>
              <div v-if="fi_type === 'pay'" class="input-group mb-2">
                <label class="form-label mx-2">연동 계좌</label>
                <input
                  type="text"
                  class="form-control"
                  data-bs-toggle="dropdown"
                  aria-expanded="false"
                  v-model="connect_account_checking"
                  readonly
                />
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
                        v-model="account_form.connection_bank"
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
                <label class="form-label mx-2">연동 카드</label>
                <input
                  type="text"
                  class="form-control"
                  data-bs-toggle="dropdown"
                  aria-expanded="false"
                  v-model="connect_card_checking"
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
                        v-model="account_form.connection_card"
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
                <label class="form-label mx-2">비고</label>
                <textarea
                  type="text"
                  class="form-control"
                  v-model="account_form.description"
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
  </div>
  <!-- Modal -->
  <dialog>
    <form method="dialog">
      <div id="dialog_body" class="container text-start">field_text</div>
      <button class="m-2 btn btn-secondary" value="close">취소</button>
      <button
        class="m-2 btn btn-info"
        data-bs-dismiss="modal"
        data-bs-target="#accoutadd"
        value="confirm"
      >
        확인
      </button>
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
      d_month: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      fi_type: "bank",
      delete_candidate: [],
      account_form: {
        name: "",
        corp: "",
        type: "",
        accountnumber: "",
        connection: "",
        connection_bank: [],
        connection_card: [],
        expiredmonth: "",
        expiredyear: "",
        description: "",
      },
    };
  },
  computed: {
    connect_account_checking: function () {
      let connect_name = [];
      for (let value of this.account_table) {
        if (
          Object.values(this.account_form.connection_bank).includes(
            value.accountnumber
          )
        ) {
          connect_name.push(value.nickname);
        }
      }
      return connect_name;
    },
    connect_card_checking: function () {
      let connect_name = [];
      for (let value of this.card_table) {
        if (
          Object.values(this.account_form.connection_card).includes(
            value.cardnumber
          )
        ) {
          connect_name.push(value.nickname);
        }
      }
      return connect_name;
    },
  },
  mounted() {
    this.get_table();
  },
  methods: {
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
    add_account() {
      let reg_exyear = /^[0-9]{4}$/;
      if (!reg_exyear.test(this.expiredyear) && this.fi_type === "card") {
        alert("만료년도를 4자리 숫자로 표시하세요");
        return false;
      }
      const dialog = document.querySelector("dialog");
      const dialog_field = dialog.querySelector("#dialog_body");
      const account_form = document.getElementById("ADD_FORM");
      const ingroup = account_form.getElementsByClassName("input-group");
      let dialog_text = "";
      for (const [key] of Object.entries(ingroup)) {
        for (const [c_key] of Object.entries(ingroup[key].children)) {
          if (
            ingroup[key].children[c_key].classList.value.includes("form-label")
          ) {
            dialog_text =
              dialog_text + ingroup[key].children[c_key].innerText + " : ";
          }
          if (ingroup[key].children[c_key].className === "form-control") {
            dialog_text = dialog_text + ingroup[key].children[c_key].value;
          }
          if (ingroup[key].children[c_key].className === "input-group-text") {
            dialog_text = dialog_text + ingroup[key].children[c_key].innerText;
          }
        }
        dialog_text = dialog_text + "<br>";
      }
      if (this.fi_type === "bank") {
        dialog_text = dialog_text + "<br>위 정보로 계좌를 추가합니다.";
      } else if (this.fi_type === "card") {
        dialog_text = dialog_text + "<br>위 정보로 카드를 추가합니다.";
      } else {
        dialog_text = dialog_text + "<br>위 정보로 페이를 추가합니다.";
      }
      dialog_field.innerHTML = dialog_text;
      dialog.addEventListener(
        "close",
        () => {
          const value = dialog.returnValue;
          if (value === "confirm") {
            if (this.fi_type === "bank") {
              axios
                .post("api/v1/account_management/bank_account/", {
                  username: this.$store.state.username,
                  nickname: this.account_form.name,
                  bankname: this.account_form.corp,
                  accountnumber: this.account_form.accountnumber,
                  account_type: this.account_form.type,
                  description: this.account_form.description,
                })
                .then((response) => {
                  console.log(response);
                  alert("Success");
                  this.get_table();
                })
                .catch((error) => {
                  console.error(error);
                });
            } else if (this.fi_type === "card") {
              axios
                .post("api/v1/account_management/card_account/", {
                  username: this.$store.state.username,
                  nickname: this.account_form.name,
                  corpname: this.account_form.corp,
                  cardnumber: this.account_form.accountnumber,
                  card_type: this.account_form.type,
                  bankconnect: this.account_form.connection,
                  description: this.account_form.description,
                })
                .then((response) => {
                  console.log(response);
                  alert("Success");
                  this.get_table();
                })
                .catch((error) => {
                  console.error(error);
                });
            } else {
              axios
                .post("api/v1/account_management/pay_account/", {
                  username: this.$store.state.username,
                  nickname: this.account_form.name,
                  corpname: this.account_form.corp,
                  assetamount: this.account_form.accountnumber,
                  description: this.account_form.description,
                  bankconnection: this.account_form.connection_bank,
                  cardconnection: this.account_form.connection_card,
                })
                .then((response) => {
                  console.log(response);
                  alert("Success");
                  this.get_table();
                })
                .catch((error) => {
                  console.log(error);
                });
            }
          }
        },
        { once: true }
      );
      dialog.showModal();
    },
    delete_account() {
      const delete_confirm = confirm("선택된 계좌들을 삭제합니까?");
      if (delete_confirm) {
        let urls = [];
        this.delete_candidate.map((obj) => {
          if (obj[1] == "bank") {
            urls.push("api/v1/account_management/bank_account/" + obj[0]);
          }
          if (obj[1] == "card") {
            urls.push("api/v1/account_management/card_account/" + obj[0]);
          }
          if (obj[1] == "pay") {
            urls.push("api/v1/account_management/pay_account/" + obj[0]);
          }
        });
        axios
          .all(urls.map((url) => axios.delete(url)))
          .then(() => {
            alert("Success");
            this.get_table();
          })
          .catch((error) => {
            console.log(error);
          });
      }
    },
    copy_number(account_number) {
      const textarea = document.createElement("textarea");
      textarea.value = account_number;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand("copy");
      document.body.removeChild(textarea);
      alert("복사되었습니다");
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
.fa-copy:hover {
  cursor: pointer;
}
</style>
