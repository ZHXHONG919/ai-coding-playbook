// 采用稿的局部交互。外壳样式不在本夹具范围。
export const adopted = {
  completionView: () => ({ page: 'operations', taskId: null, resultId: null }),
  taskView: task => ({ page: 'result-detail', taskId: task.id, resultId: task.results[0] }),
  generate: detail => ({ ...detail, sheet: 'generation' }),
  close: detail => ({ ...detail, sheet: null }),
};
