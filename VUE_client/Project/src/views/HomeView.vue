<template>
  <div class="home" v-if="this.$store.state.isAuthenticated">
    <img alt="Vue logo" :src="require('@/assets/logo.png')" />
    <!-- <HelloWorld msg="Welcome to Your Vue.js App" /> -->
  </div>
  <div class="home-unsigned" @keyup.enter="submitLoginForm" v-else>
    <!-- <img :src="require('@/assets/BG.png')" alt="background" class="bg" /> -->
    <div class="w-100 h-100 d-flex align-items-center justify-content-center">
      <div id="login-box" class="p-2">
        <div id="login-box-id" class="text-center mt-4">
          <!-- <Transition name="login-process">
            <p v-if="step1">hello3</p>
          </Transition> -->
          <div class="mx-4 text-start login-propoerty">
            <label class="form-label" style="font-weight: bold">아이디</label>
            <input
              type="text"
              class="form-control"
              v-model="userId"
              placeholder="somename@email.com"
              required
            />
          </div>
          <div class="mx-4 text-start login-propoerty">
            <label class="form-label" style="font-weight: bold">비밀번호</label>
            <input
              type="password"
              class="form-control"
              v-model="userPassword"
              placeholder="password"
              required
            />
          </div>
          <div class="m-auto p-2 text-start login-propoerty">
            <div v-if="login_error" id="login-error-box">
              아이디나 비밀번호가 <br />
              잘못 입력되어있습니다
            </div>
          </div>
          <div class="mx-4 text-start login-propoerty">
            <button
              class="btn btn-success fw-bold w-100"
              @click="submitLoginForm"
            >
              아이디로 로그인
            </button>
          </div>
        </div>
        <div class="mt-3 border-top p-4">
          <button
            class="sns-button btn mx-3"
            style="background: rgb(237, 237, 35)"
          ></button>
          <button
            class="sns-button btn mx-3"
            style="background: rgb(193, 24, 24)"
          ></button>
          <div class="sns-button" style="align-content: center">
            <SymbolS :plus="true" :size="2" />
          </div>
          <button class="btn btn-dark mx-3" id="signup-button">
            <router-link id="signup-ahref" to="/signup">
              계정생성하기</router-link
            >
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import SymbolS from "@/components/SymbolComponent.vue";
// @ is an alias to /src
// import HelloWorld from "@/components/HelloWorld.vue";

export default {
  name: "HomeView",
  components: {
    SymbolS,
    // HelloWorld,
  },
  data() {
    return {
      userId: null,
      userPassword: null,
      login_error: false,
    };
  },
  methods: {
    submitLoginForm() {
      if (this.userId === null || this.userId === "") {
        alert("아이디를 입력하세요");
        return;
      }
      if (this.userPassword === null || this.userPassword === "") {
        alert("비밀번호를 입력하세요");
        return;
      }
      axios
        .post("/auth/token/login", {
          username: this.userId,
          password: this.userPassword,
        })
        .then((response) => {
          const token = response.data.auth_token;
          this.userId - null;
          this.userPassword = null;
          this.$store.commit("setToken", token);
          axios.defaults.headers.common["Authorization"] = "Token " + token;

          localStorage.setItem("token", token);
        })
        .catch(() => {
          this.login_error = true;
        });
    },
  },
};
</script>

<style>
@media (min-width: 500px) {
  #login-error-box br {
    display: none;
  }
}
.home-unsigned {
  height: 100vh;
  width: 100vw;
  background: linear-gradient(to right, rgb(66, 231, 237), rgb(255, 0, 179));
  /* background-repeat: no-repeat;
  background-size: cover;
  background-image: url("@/assets/BG.png"); */
}
#login-box {
  width: 512px;
  height: 384px;
  max-width: 80vw;
  max-height: 80vh;
  border-radius: 25px;
  background-color: white;
}
#login-box-id {
  width: 100%;
  height: 70%;
}
#login-error-box {
  text-align: center;
  color: red;
  border-color: red;
  border: 1px solid;
  height: 5%;
  margin: auto;
}
#signup-button {
  border-radius: 2.4rem;
  height: 2.4rem;
}
#signup-ahref {
  text-decoration: none;
  color: white;
  font-weight: bold;
}
/* .grayfilter {
  background-color: rgba(0, 0, 0, 0.25);
} */
.sns-button {
  border-radius: 100%;
  height: 2.4rem;
  width: 2.4rem;
}
.login-propoerty {
  width: 90%;
}
/* .login-process-enter-active,
.login-process-leave-active {
  transition: opacity 0.5s ease;
}

.login-process-enter-from,
.login-process-leave-to {
  opacity: 0;
} */
</style>
