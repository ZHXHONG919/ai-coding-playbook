const {test} = require("node:test");
const assert = require("node:assert/strict");
const {Flow} = require("./flow.cjs");
test("上传返回完整方案", async () => {
  const f = new Flow(async () => ({required:true, images:["image"]}));
  const plan = await f.uploadImages(["image"]);
  assert.equal(plan.required, true);
});

test("上传期间阻止预览，上传成功后询问补充且允许手动预览", async () => {
  let completeUpload;
  const plan = {required:true, images:["image"]};
  const f = new Flow((images) => {
    assert.deepEqual(images, ["image"]);
    return new Promise((resolve) => { completeUpload = resolve; });
  });
  const uploading = f.uploadImages(["image"]);
  assert.equal(f.loading, true);
  assert.equal(f.preview(), false);
  assert.equal(f.page, "edit");

  completeUpload(plan);
  assert.equal(await uploading, plan);
  assert.equal(f.loading, false);
  assert.equal(f.askMore, true);
  assert.equal(f.supplementingFinished, false);
  assert.equal(f.page, "edit");
  assert.equal(f.canPreview, true);
  assert.equal(f.preview(), true);
  assert.equal(f.page, "preview");
});

test("继续补充不自动预览，明确不再补充才自动预览", async () => {
  const f = new Flow(async () => ({required:true, images:["image"]}));
  await f.uploadImages(["image"]);
  f.answerSupplement(true);
  assert.equal(f.askMore, false);
  assert.equal(f.supplementingFinished, false);
  assert.equal(f.page, "edit");
  assert.equal(f.canPreview, true);

  await f.uploadImages(["another-image"]);
  assert.equal(f.askMore, true);
  assert.equal(f.page, "edit");
  f.answerSupplement(false);
  assert.equal(f.askMore, false);
  assert.equal(f.supplementingFinished, true);
  assert.equal(f.page, "preview");
});

test("未明确回答不再补充时不自动预览", async () => {
  for (const answer of [undefined, null, 0, ""]) {
    const f = new Flow(async () => ({required:true, images:["image"]}));
    await f.uploadImages(["image"]);
    f.answerSupplement(answer);
    assert.equal(f.supplementingFinished, false);
    assert.equal(f.page, "edit");
    assert.equal(f.preview(), true);
  }
});

test("已有完整方案时补传期间仍不能预览，补传失败保留方案并可重试", async () => {
  const previousPlan = {required:true, images:["image"]};
  const updatedPlan = {required:true, images:["image", "another-image"]};
  let calls = 0;
  let failUpload;
  const f = new Flow(() => {
    if (++calls === 1) return Promise.resolve(previousPlan);
    if (calls === 2) return new Promise((resolve, reject) => { failUpload = reject; });
    return Promise.resolve(updatedPlan);
  });
  await f.uploadImages(["image"]);
  f.answerSupplement(true);
  const uploading = f.uploadImages(["another-image"]);
  assert.equal(f.dataReady, true);
  assert.equal(f.canPreview, false);
  assert.equal(f.preview(), false);
  assert.equal(f.page, "edit");
  const rejection = assert.rejects(uploading, /upload failed/);
  failUpload(new Error("upload failed"));
  await rejection;
  assert.equal(f.loading, false);
  assert.equal(f.plan, previousPlan);
  assert.equal(f.canPreview, true);

  assert.equal(await f.uploadImages(["another-image"]), updatedPlan);
  assert.equal(f.askMore, true);
  assert.equal(f.page, "edit");
  assert.equal(f.preview(), true);
});

for (const plan of [null, {required:false, images:["image"]}, {required:true, images:[]}]) {
  test(`数据不完整时手动和自动预览均被阻止：${JSON.stringify(plan)}`, async () => {
    const f = new Flow(async () => plan);
    await f.uploadImages(["image"]);
    assert.equal(f.loading, false);
    assert.equal(f.canPreview, false);
    assert.equal(f.preview(), false);
    f.answerSupplement(false);
    assert.equal(f.page, "edit");
  });
}

test("上传失败清理忙碌状态，重试后可预览", async () => {
  const uploadError = new Error("upload failed");
  let calls = 0;
  const f = new Flow(async (images) => {
    assert.deepEqual(images, ["image"]);
    if (++calls === 1) throw uploadError;
    return {required:true, images:["image"]};
  });
  await assert.rejects(f.uploadImages(["image"]), (error) => error === uploadError);
  assert.equal(f.loading, false);
  assert.equal(f.plan, null);
  assert.equal(f.askMore, false);
  assert.equal(f.page, "edit");

  await f.uploadImages(["image"]);
  assert.equal(calls, 2);
  assert.equal(f.loading, false);
  assert.equal(f.askMore, true);
  assert.equal(f.preview(), true);
  assert.equal(f.page, "preview");
});
