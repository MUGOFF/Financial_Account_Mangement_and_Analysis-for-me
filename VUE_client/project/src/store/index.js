import { createStore } from "vuex";
import axios from "axios";

export default createStore({
  state: {
    token: "",
    username: "",
    isAuthenticated: false,
    isLoading: false,
  },
  getters: {},
  mutations: {
    initializeStore(state) {
      if (localStorage.getItem("token")) {
        state.token = localStorage.getItem("token");
        state.username = localStorage.getItem("username");
        state.isAuthenticated = true;
      } else {
        state.token = "";
        state.username = "";
        state.isAuthenticated = false;
      }
    },
    setToken(state, token) {
      state.token = token;
      state.isAuthenticated = true;
    },
    setUsername(state, username) {
      state.username = username;
    },
    removeItems(state) {
      state.token = "";
      state.username = "";
      state.isAuthenticated = false;
      localStorage.removeItem("token");
      localStorage.removeItem("username");
      location.reload;
    },
    setIsLoading(state, status) {
      state.isLoading = status;
    },
  },
  actions: {
    async checkTokenValidity({ commit, state }) {
      // check for valid auth token
      await axios
        .get("/auth/valdiation/token/?token=" + state.token)
        .then(() => {
          return true;
        })
        .catch(() => {
          commit("removeItems");
          axios.defaults.headers.common["Authorization"] = "";
        });
    },
  },
  modules: {},
});
