<template>
  <div :style="'font-size:' + size + 'px'">
    <div class="plus" v-if="plus"></div>
  </div>
</template>
<script>
export default {
  name: "SymbolS",
  props: {
    plus: {
      type: Boolean,
      default: () => false,
    },
    size: {
      type: Number,
      default: () => 20,
    },
  },
};
</script>
<style>
div {
  display: inline-block;
}
.plus {
  position: relative;
  width: 10em;
  height: 10em;
}

.plus:before,
.plus:after {
  content: "";
  position: absolute;
  background: black;
}

/* the vertical line */
.plus:before {
  left: 50%;
  top: 1px; /* this defines how much black "border" there should be */
  bottom: 1px;
  width: 2em;
  border-radius: 2em;
  transform: translateX(-50%);
}

/* the horizontal line */
.plus:after {
  top: 50%;
  left: 1px;
  right: 1px;
  height: 2em;
  border-radius: 2em;
  transform: translateY(-50%);
}
</style>
