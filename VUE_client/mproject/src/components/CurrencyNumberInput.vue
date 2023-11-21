<template>
  <div>
    <input
      type="text"
      :class="this.class"
      v-model="price_display"
      @click="InitModel()"
      @blur="isInputActive = false"
      @focus="isInputActive = true"
    />
  </div>
</template>
<script>
export default {
  name: "CurrencyLocale",
  data() {
    return {
      isInputActive: false,
    };
  },
  computed: {
    price_display: {
      get() {
        if (this.isInputActive) {
          return this.modelValue.toString();
        } else {
          return this.modelValue.toLocaleString("ko-KR", {
            style: "currency",
            currency: "KRW",
          });
        }
      },
      set(value) {
        let newValue = Number(value);
        if (isNaN(newValue)) {
          newValue = 0;
        }
        // 부모에게 전달
        this.$emit("update:modelValue", newValue);
      },
    },
  },
  props: {
    modelValue: {
      type: Number,
      default: () => 0,
    },
    class: {
      type: String,
      default: () => "",
    },
  },
  methods: {
    InitModel() {
      this.$emit("update:modelValue", "");
    },
  },
};
</script>
<style></style>
