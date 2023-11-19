<template>
  <div id="signup-page">
    <div class="w-100 h-100">
      <div class="w-25 h-50 position-absolute top-50 start-50 translate-middle">
        <div class="w-100 h-100 p-3 rounded shadow text-start" id="signup-box">
          <div class="w-100 h-75">
            <label for="email-id" class="form-label">아이디</label>
            <div class="input-group">
              <input
                type="text"
                id="email-id"
                v-model="id_email"
                placeholder="username@email.com"
                class="form-control"
              />
              <transition name="slide-fade">
                <button
                  class="btn btn-outline-primary"
                  type="button"
                  v-if="!isUsernameChecked"
                  @click="CheckDuplicateID"
                >
                  중복 확인하기
                </button>
                <button class="btn btn-primary" type="button" v-else>
                  <i class="fa-solid fa-check"></i>
                </button>
              </transition>
            </div>
            <label for="password" class="form-label">패스워드</label>
            <div class="form-control">
              <input
                :type="isPasswordVisible ? 'password' : 'text'"
                id="password"
                v-model="password"
                class="password-bar"
              />
              <button class="eye-button" type="button" @click="PasswordVisible">
                <i v-if="isPasswordVisible" class="fa-solid fa-eye-slash"></i>
                <i v-else class="fa-solid fa-eye"></i>
              </button>
            </div>
            <label for="retype-password" class="form-label"
              >패스워드 재입력</label
            >
            <div class="form-control">
              <input
                :type="isRePasswordVisible ? 'password' : 'text'"
                id="retype-password"
                v-model="retype_password"
                class="password-bar"
              />
              <button
                class="eye-button"
                type="button"
                @click="RePasswordVisible"
              >
                <i v-if="isRePasswordVisible" class="fa-solid fa-eye-slash"></i>
                <i v-else class="fa-solid fa-eye"></i>
              </button>
              <span v-if="!isPasswordMatch">패스워드가 일치하지 않습니다.</span>
            </div>
          </div>
          <div class="w-100 h-25 pt-4 text-center">
            <button class="btn w-75 btn-primary" type="button" @click="signup">
              가입하기
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import axios from "axios";

export default {
  data() {
    return {
      id_email: "",
      pasword: "",
      try_signup: false,
      isUsernameChecked: false,
      isPasswordVisible: true,
      isRePasswordVisible: true,
    };
  },
  computed: {
    isPasswordMatch() {
      return this.password === this.retype_password;
    },
  },
  methods: {
    async signup() {
      this.try_signup = true;
      if (!this.isUsernameChecked) {
        alert("중복 아이디를 체크하십시오");
        return;
      }
      if (!this.isPasswordMatch) {
        alert("비밀번호가 일치하지 않습니다");
        return;
      }
      await axios
        .post("/auth/users/", {
          email: this.id_email,
          username: this.id_email,
          password: this.password,
        })
        .then(() => {
          alert("가입되었습니다.");
          this.$router.push({
            name: "home",
          });
        })
        .catch((error) => {
          console.error(error);
        });
    },
    async CheckDuplicateID() {
      // 임시 비번
      // const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
      // const randomnumber = Math.floor(Math.random() * 10);
      // const randomIndex = charset[Math.floor(Math.random() * charset.length)];
      // const seed = Date.now();
      // const hash = Math.abs(Math.sin(seed)).toString(36).substring(2);
      // let temp_password = randomIndex + hash + randomnumber;
      await axios
        .get("/auth/valdiation/?username=" + this.id_email)
        .then(() => {
          this.isUsernameChecked = true;
        })
        .catch(() => {
          alert("이미 존재하는 이메일주소입니다");
        });
    },
    PasswordVisible() {
      this.isPasswordVisible = !this.isPasswordVisible;
    },
    RePasswordVisible() {
      this.isRePasswordVisible = !this.isRePasswordVisible;
    },
  },
};
</script>
<style>
#signup-page {
  width: 100vw;
  height: 100vh;
}
#signup-box {
  display: inline-block;
}
.eye-button {
  border: none;
  background-color: transparent;
}
.password-bar {
  width: 90%;
  border: none;
  background-color: transparent;
}
.password-bar:focus {
  width: 90%;
  outline: 0;
}
.slide-fade-enter-active {
  transition: all 0.5s ease;
}
.slide-fade-leave-active {
  transition: all 0.5s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter,
.slide-fade-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}
</style>
