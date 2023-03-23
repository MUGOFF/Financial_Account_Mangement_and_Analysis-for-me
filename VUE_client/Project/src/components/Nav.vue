<template>
  <nav class="navbar navbar-expand-lg">
    <div class="container-fluid">
      <button
        class="navbar-toggler"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#navbarScroll"
        aria-controls="navbarScroll"
        aria-expanded="false"
        aria-label="Toggle navigation"
      >
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarScroll">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0 navbar-nav-scroll">
          <li class="nav-item">
            <router-link class="nav-link" aria-current="true" to="/"
              >메인 홈</router-link
            >
          </li>
          <!-- info -->
          <li class="nav-item dropdown">
            <router-link
              class="nav-link dropdown-toggle"
              role="button"
              aria-current="page"
              data-bs-toggle="dropdown"
              aria-haspopup="true"
              aria-expanded="false"
              to="#"
              >계좌</router-link
            >
            <!-- <router-link class="dropdown-item" to="/"></router-link> -->
            <ul class="dropdown-menu" aria-labelledby="navbarDropdown">
              <li>
                <router-link class="dropdown-item" to="/accountmanage"
                  >계좌 입력</router-link
                >
              </li>
              <li>
                <router-link class="dropdown-item" to="/addtable"
                  >거래 기록표 입력</router-link
                >
              </li>
            </ul>
          </li>
          <!-- book -->
          <li class="nav-item dropdown">
            <router-link
              class="nav-link dropdown-toggle"
              aria-current="page"
              data-bs-toggle="dropdown"
              aria-haspopup="true"
              aria-expanded="false"
              to="#"
              >가계부</router-link
            >
            <ul class="dropdown-menu">
              <li>
                <router-link class="dropdown-item" to="/book"
                  >가계부 보기</router-link
                >
              </li>
              <li>
                <router-link class="dropdown-item" to="/budget"
                  >예산 설정</router-link
                >
              </li>
              <!-- <li>
                <router-link class="nav-link" to="/"></router-link>
              </li> -->
            </ul>
          </li>
          <!-- analysis -->
          <li class="nav-item dropdown">
            <router-link
              class="nav-link dropdown-toggle"
              aria-current="page"
              data-bs-toggle="dropdown"
              aria-haspopup="true"
              aria-expanded="false"
              to="#"
              >분석</router-link
            >
            <ul class="dropdown-menu">
              <li>
                <router-link class="nav-link" to="/anlysis"
                  >자산 분석</router-link
                >
              </li>
              <li>
                <router-link class="nav-link" to="/"></router-link>
              </li>
              <li>
                <router-link class="nav-link" to="/"></router-link>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</template>
<script>
export default {
  name: "NavBar",
};
</script>
<style lang=""></style>
