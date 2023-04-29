<template>
  <NavBar />
  <!-- <nav class="navbar navbar-expand-lg">
    <router-link to="/">Home</router-link> |
    <router-link to="/addtable">Account Data</router-link> |
    <router-link to="/about">Data Analysis</router-link> |
  </nav> -->
  <!-- <router-link to="/testpage">page_test</router-link> -->
  <router-view />
  <div
    class="w-100 h-100 fixed-top"
    id="spinner-container"
    v-show="this.$store.state.isLoading"
  >
    <div class="spinner-border" role="status" style="width: 25vh; height: 25vh">
      <span class="visually-hidden">Loading...</span>
    </div>
  </div>
</template>

<script>
import NavBar from "@/components/Nav.vue";
export default {
  name: "App",
  components: {
    NavBar,
  },
};
</script>

<style lang="scss">
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

nav {
  padding: 30px;

  a {
    font-weight: bold;
    color: #2c3e50;

    &.router-link-exact-active {
      color: #42b983;
    }
  }
}

#spinner-container {
  display: grid;
  place-items: center;
  backdrop-filter: blur(5px);
}
</style>
