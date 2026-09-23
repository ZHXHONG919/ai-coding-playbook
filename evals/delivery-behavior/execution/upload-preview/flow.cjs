// 简化的页面状态控制器。实际供应方由调用者注入。
class Flow {
  constructor(upload) {
    this.upload = upload;
    this.loading = false;
    this.plan = null;
    this.askMore = false;
    this.supplementingFinished = false;
    this.page = "edit";
  }
  get dataReady() { return Boolean(this.plan?.required && this.plan?.images?.length); }
  get canPreview() { return !this.loading && this.dataReady; }
  preview() {
    if (!this.canPreview) return false;
    this.page = "preview";
    return true;
  }
  async uploadImages(images) {
    this.loading = true;
    this.plan = await this.upload(images);
    this.askMore = true;
    return this.plan;
  }
  answerSupplement(more) {
    this.askMore = false;
    this.supplementingFinished = !more;
    if (!more) this.preview();
  }
}
module.exports = {Flow};
