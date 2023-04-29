import { createApp } from "vue";
import App from "./App.vue";
import "./registerServiceWorker";
import "bootstrap";
import VCalendar from "v-calendar";
import "v-calendar/style.css";
import router from "./router";
import store from "./store";
import axios from "axios";

axios.defaults.baseURL = "http://127.0.0.1:8000";

axios.defaults.xsrfCookieName = "csrftoken";
axios.defaults.xsrfHeaderName = "X-CSRFToken";

createApp(App).use(VCalendar, {}).use(store).use(router, axios).mount("#app");
