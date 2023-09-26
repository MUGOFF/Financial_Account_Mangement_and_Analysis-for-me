<!-- <template>
  <div class="login">
    <div class="title">
      <span style="font-weight: bold; font-size: 1.5em">로그인</span>
    </div>
    <form
      class="needs-validation"
      novalidate
      @submit.prevent="submitLoginForm"
      align="left"
    >
      <div class="mb-3">
        <label class="form-label" style="font-weight: bold">아이디</label>
        <input
          type="text"
          class="form-control"
          v-model="userId"
          placeholder="yourname@email.com"
          required
        />
      </div>
      <div class="mb-3">
        <label class="form-label" style="font-weight: bold">비밀번호</label>
        <input
          type="password"
          class="form-control"
          v-model="userPassword"
          placeholder="password"
          required
        />
      </div>
      <button type="submit" class="btn btn-primary w-100">로그인</button>
    </form>
    <br />
    <div align="center">
      <span style="color: gray">계정이 없습니까? </span
      ><router-link to="/signup"
        ><span
          style="
            color: rgba(0, 0, 0, 0.8);
            text-decoration-line: underline;
            font-weight: bold;
          "
          >회원가입</span
        ></router-link
      >
    </div>
    <div align="center">
      <router-link to="/signup"
        ><span
          style="
            color: rgba(0, 0, 0, 0.8);
            text-decoration-line: underline;
            font-weight: bold;
          "
          >아이디 찾기</span
        ></router-link
      >/
      <router-link to="/signup"
        ><span
          style="
            color: rgba(0, 0, 0, 0.8);
            text-decoration-line: underline;
            font-weight: bold;
          "
          >비밀번호 찾기</span
        ></router-link
      >
    </div>
  </div>
</template>

<script>
import axios from "axios";
export default {
  data() {
    return {
      userId: null,
      userPassword: null,
    };
  },
  methods: {
    submitLoginForm() {
      axios
        .post("/api/v1/token/login", {
          username: this.userId,
          password: this.userPassword,
        })
        .then((response) => {
          console.log(response.data);
          const token = response.data.auth_token;

          this.$store.commit("setToken", token);
          axios.defaults.headers.common["Authorization"] = "Token " + token;

          localStorage.setItem("token", token);
          this.$router.push("/");
        })
        .catch((error) => {
          alert(error.request.response);
        });
    },
  },
};
</script>
<style scoped>
.login {
  width: 700px;
  margin: auto;
  padding-top: 100px;
}

.btn {
  /* color: #000; */
  background-color: #c0ffee;
  border: none;
}

.btn:hover {
  /* color: #000; */
  background-color: #799b6a;
  border: none;
}
</style> -->
