const {test} = require("node:test");
const assert = require("node:assert/strict");
const {Flow} = require("./flow.cjs");
test("上传返回完整方案", async () => {
  const f = new Flow(async () => ({required:true, images:["image"]}));
  const plan = await f.uploadImages(["image"]);
  assert.equal(plan.required, true);
});
