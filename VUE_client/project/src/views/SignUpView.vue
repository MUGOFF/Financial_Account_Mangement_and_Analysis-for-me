<template>
  <div id="signup-page">
    <div class="w-100 h-100">
      <div
        class="h-50 position-absolute top-50 start-50 translate-middle"
        style="width: 500px"
      >
        <div class="w-100 h-100 p-3 rounded shadow text-start" id="signup-box">
          <div class="w-100 h-75">
            <label for="email-id" class="form-label content-title"
              >아이디</label
            >
            <div class="input-group">
              <input
                type="text"
                id="email-id"
                v-model="id_email_head"
                :disabled="isUsernameChecked"
                placeholder="username"
                class="form-control col-4"
              />
              <span class="input-group-text text-center">@</span>
              <input
                type="text"
                id="email-site"
                :disabled="isUsernameChecked"
                list="mail_list"
                v-model="id_email_site"
                placeholder="email.com"
                class="form-control col-4"
              />
              <datalist id="mail_list">
                <option>gmail.com</option>
                <option>naver.com</option>
              </datalist>
              <button
                class="col-4 btn btn-primary"
                :class="{
                  disabled: EmailTextCombined == '@' || isUsernameChecked,
                }"
                type="button"
                v-if="!isUsernameChecked"
                @click="CheckDuplicateID"
              >
                <!-- 'btn-primary': isUsernameChecked, -->
                <!-- 'btn-outline-primary': !isUsernameChecked, -->
                <!-- <transition name="slide-fade">
                  <div v-if="!isUsernameChecked">
                    <span>중복 확인하기</span>
                  </div>
                  <div v-else>
                    <i class="fa-solid fa-check"></i>
                  </div>
                </transition> -->
                <span>중복 확인하기</span>
              </button>

              <div class="col-4 btn btn-primary" v-else>
                <Transition name="bounce">
                  <div v-if="!isUsernameChecked">
                    <span>중복 확인하기</span>
                  </div>
                  <div v-else>
                    <i class="fa-solid fa-check"></i>
                  </div>
                </Transition>
              </div>
            </div>
            <label for="password" class="form-label content-title"
              >패스워드</label
            >
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
            <label for="retype-password" class="form-label content-title"
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
            </div>
            <span
              v-if="!isPasswordMatch && retype_password !== ''"
              class="text-danger"
              >패스워드가 일치하지 않습니다.</span
            >
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
      id_email_head: "",
      id_email_site: "",
      password: "",
      retype_password: "",
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
    EmailTextCombined() {
      return this.id_email_head + "@" + this.id_email_site;
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
          email: this.EmailTextCombined,
          username: this.EmailTextCombined,
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
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      const validateEmail = emailRegex.test(this.EmailTextCombined);
      if (!validateEmail) {
        alert("이메일을 입력해주세요");
        return;
      }
      if (this.isUsernameChecked) {
        alert("이미 확인 했습니다");
        return;
      }
      await axios
        .get("/auth/valdiation/?username=" + this.EmailTextCombined)
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
.bounce-enter-active {
  animation: bounce-in 0.5s;
}
.content-title {
  margin-top: 1vh;
}
@keyframes bounce-in {
  0% {
    transform: scale(0);
  }
  100% {
    transform: scale(1.5);
  }
}
</style>
