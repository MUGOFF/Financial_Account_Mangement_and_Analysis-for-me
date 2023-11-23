<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div>
    <span
      v-for="(hashtag, index) in hashtags"
      :key="index"
      class="hashtag"
      @dblclick="removeHashtag(index)"
      >#{{ hashtag }}</span
    >
  </div>
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

<style>
.hashtag {
  color: blue;
  background-color: #d0d0d0;
  margin-right: 8px;
  margin-left: 2px;
  cursor: pointer;
}
.hashtag:hover {
  background-color: #707070;
}
</style>
