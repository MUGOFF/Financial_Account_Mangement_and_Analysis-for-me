import { createRouter, createWebHistory } from "vue-router";
import HomeView from "../views/HomeView.vue";

const routes = [
  {
    path: "/",
    name: "home",
    component: HomeView,
  },
  {
    path: "/about",
    name: "about",
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () =>
      import(/* webpackChunkName: "about" */ "@/views/AboutView.vue"),
  },
  {
    path: "/testpage",
    name: "testpage",
    component: () => import("@/views/TestVue.vue"),
  },
  // 계좌 정보 info
  {
    path: "/addtable",
    name: "AddTable",
    component: () => import("@/views/AddTable.vue"),
  },
  {
    path: "/accountmanage",
    name: "AccountManagement",
    component: () => import("@/views/AccountManagement.vue"),
  },
  {
    path: "/transaction",
    name: "TransactionManagement",
    component: () => import("@/views/TransactionManagement.vue"),
  },
  {
    path: "/transaction/create",
    name: "TransactionCreate",
    component: () => import("@/views/TransactionCreate.vue"),
  },
  {
    path: "/transaction/:transactionId",
    name: "TransactionDetail",
    component: () => import("@/views/TransactionDetail.vue"),
  },
  // {
  //   path: "/",
  //   name: "",
  //   component: () => import("@/views/"),
  // },
  // 가계부 Book
  {
    path: "/book",
    name: "BookView",
    component: () => import("@/views/BookView.vue"),
  },
  {
    path: "/budget",
    name: "BudgetView",
    component: () => import("@/views/BudgetView.vue"),
  },
  // 자산분석 Analysis
  {
    path: "/anlysis",
    name: "AssetAnalysis",
    component: () => import("@/views/AssetAnalysis.vue"),
  },
  // 로그인 제외
  // {
  //   path: "/login",
  //   name: "LoginPage",
  //   component: () => import("@/views/LoginView.vue"),
  // },
  {
    path: "/signup",
    name: "SingupPage",
    component: () => import("@/views/SignUpView.vue"),
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
});

export default router;
