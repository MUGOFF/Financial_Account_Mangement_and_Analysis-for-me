<template>
  <button
    type="button"
    class="btn m-2 btn-primary"
    data-bs-toggle="modal"
    data-bs-target="#accoutadd"
  >
    계좌 추가
  </button>
  <!-- Modalstart bootstrap -->
  <div
    class="modal fade"
    id="accoutadd"
    data-bs-backdrop="static"
    data-bs-keyboard="false"
    tabindex="-1"
    aria-labelledby="accoutaddLabel"
    aria-hidden="true"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="accoutaddLabel">Modal title</h1>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>
        <form id="ADD_FORM" @submit.prevent="add_account()">
          <div class="modal-body">
            <div class="input-group mb-2">
              <label class="form-label mx-2">이름</label>
              <input
                type="text"
                class="form-control"
                v-model="account_form.name"
                required
              />
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              data-bs-dismiss="modal"
            >
              닫기
            </button>
            <button type="submit" class="btn btn-primary">확인</button>
          </div>
        </form>
      </div>
    </div>
  </div>
  <!-- Modalend -->
</template>
<script>
export default {};
</script>
<style></style>
