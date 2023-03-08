<template>
  <div id="search">
    <div id="search-table">
      <table class="table table-bordered" style="width: 100%">
        <thead>
          <tr>
            <th scope="col" style="width: 25%">지역</th>
            <th scope="col" style="width: 25%">상세지역</th>
            <th scope="col" style="width: 25%">품목</th>
            <th scope="col" style="width: 25%">규모</th>
          </tr>
        </thead>
        <tbody>
          <td>
            <ul class="list-group list-group-flush" id="select-region">
              <li
                class="list-group-item borderless"
                v-for="region in regions"
                :key="region"
              >
                <div class="form-check">
                  <input
                    class="form-check-input"
                    type="radio"
                    name="region"
                    id="{{item.region}}"
                    v-model="picked.region"
                    :value="region"
                  />
                  <label class="form-check-label" for="{{region}}">{{
                    region
                  }}</label>
                </div>
              </li>
            </ul>
          </td>
          <td>
            <ul class="list-group list-group-flush">
              <li
                class="list-group-item borderless"
                v-for="subregion in subregions[picked.region]"
                :key="subregion"
              >
                <div class="form-check">
                  <input
                    class="form-check-input"
                    type="radio"
                    name="sub_region"
                    id="{{subregion}}"
                    v-model="picked.subregion"
                    :value="subregion"
                  />
                  <label class="form-check-label" for="{{subregion}}">{{
                    subregion
                  }}</label>
                </div>
              </li>
            </ul>
          </td>
          <td>
            <ul class="list-group list-group-flush">
              <li
                class="list-group-item borderless"
                v-for="category in category_items"
                :key="category"
              >
                <div class="form-check">
                  <input
                    class="form-check-input"
                    type="radio"
                    name="category"
                    id="category"
                    v-model="picked.category"
                    :value="category"
                  />
                  <label class="form-check-label" for="category">{{
                    category
                  }}</label>
                </div>
              </li>
            </ul>
          </td>
          <td>
            <ul class="list-group list-group-flush">
              <li
                class="list-group-item borderless"
                v-for="scale in scale_items"
                :key="scale"
              >
                <div class="form-check">
                  <input
                    class="form-check-input"
                    type="radio"
                    name="scale"
                    id="scale"
                    v-model="picked.scale"
                    :value="scale"
                  />
                  <label class="form-check-label" for="scale"
                    >{{ scale }} 천원 이상</label
                  >
                </div>
              </li>
            </ul>
          </td>
        </tbody>
      </table>
    </div>
    <button type="button" class="btn btn-success" @click="reset">초기화</button
    >&nbsp;&nbsp;
    <button type="button" class="btn btn-success" @click="submitform">
      검색
    </button>
  </div>
</template>
<script>
export default {
  data() {
    return {
      regions: ["서울", "부산", "대구", "광주", "대전"],
      subregions: {
        서울: [
          "종로구",
          "중구",
          "용산구",
          "성동구",
          "광진구",
          "동대문구",
          "중랑구",
          "성북구",
          "강북구",
          "도봉구",
          "노원구",
          "은평구",
          "서대문구",
          "마포구",
          "양천구",
          "강서구",
          "구로구",
          "금천구",
          "영등포구",
          "동작구",
          "관악구",
          "서초구",
          "강남구",
          "송파구",
          "강동구",
        ],
        부산: [
          "중구",
          "서구",
          "동구",
          "영도구",
          "부산진구",
          "동래구",
          "남구",
          "북구",
          "강서구",
          "해운대구",
          "사하구",
          "금정구",
          "연제구",
          "수영구",
          "사상구",
          "기장군",
        ],
        대구: [
          "중구",
          "동구",
          "서구",
          "남구",
          "북구",
          "수성구",
          "달서구",
          "달성군",
        ],
        광주: ["동구", "서구", "남구", "북구", "광산구"],
        대전: ["동구", "중구", "서구", "유성구", "대덕구"],
      },
      picked: {
        region: "",
        subregion: "",
        category: "",
        scale: "",
      },
      category_items: [
        "당근",
        "무",
        "배",
        "배추",
        "사과",
        "상추",
        "수박",
        "시금치",
        "양파",
        "양배추",
        "오이",
        "토마토",
        "파",
        "포도",
        "풋고추",
      ],
      scale_items: ["1000", "5000", "10000", "50000", "100000"],
    };
  },
  name: "SearchDetail",
  components: {},
  methods: {
    submitform() {
      this.$router.push({
        name: "SearchdetailResult",
        query: {
          region: this.picked.region,
          subregion: this.picked.subregion,
          category: this.picked.category,
          scale: this.picked.scale,
        },
      });
    },
    reset() {
      this.picked.region = null;
      this.picked.subregion = null;
      this.picked.category = null;
      this.picked.scale = null;
    },
  },
};
</script>
<style scoped>
#search-table {
  margin-top: 50px;
  margin-bottom: 50px;
  margin-left: 100px;
  margin-right: 100px;
  height: 500px;
  overflow: auto;
}
.btn {
  width: 150px;
  margin-bottom: 20px;
}
</style>
