<template>
  <nav class="navbar navbar-expand-lg">
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav">
        <li class="nav-item">
          <router-link class="nav-link" aria-current="true" to="/"
            >메인 홈</router-link
          >
        </li>
        <li class="nav-item">
          <router-link class="nav-link" aria-current="true" to="/"
            >계좌 정보</router-link
          >
          <ul class="dropdown-menu">
            <li>
              <router-link class="nav-link" to="/"></router-link>
            </li>
            <li>
              <router-link class="nav-link" to="/"></router-link>
            </li>
            <li>
              <router-link class="nav-link" to="/"></router-link>
            </li>
          </ul>
        </li>
        <!-- book -->
        <li class="nav-item">
          <router-link class="nav-link" aria-current="true" to="/"
            >가계부</router-link
          >
          <ul class="dropdown-menu">
            <li>
              <router-link class="nav-link" to="/"></router-link>
            </li>
            <li>
              <router-link class="nav-link" to="/"></router-link>
            </li>
            <li>
              <router-link class="nav-link" to="/"></router-link>
            </li>
          </ul>
        </li>
        <!-- analysis -->
        <li class="nav-item">
          <router-link class="nav-link" aria-current="true" to="/"
            >자산 분석</router-link
          >
          <ul class="dropdown-menu">
            <li>
              <router-link class="nav-link" to="/"></router-link>
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
  </nav>
</template>
<script>
export default {};
</script>
<style lang=""></style>
