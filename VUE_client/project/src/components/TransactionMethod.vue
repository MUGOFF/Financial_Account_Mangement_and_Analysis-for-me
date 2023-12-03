<template>
  <div></div>
</template>
<script>
export default {
  props: {
    hashtags: {
      type: Array,
      default: () => [],
    },
  },
  methods: {
    removeHashtag(index) {
      this.$emit("remove-hashtag", index);
    },
  },
};
</script>
<style></style>
