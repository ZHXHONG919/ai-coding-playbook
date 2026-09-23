import { pathToFileURL } from 'node:url';

export const tasks = [
  { id: 'task-amber', results: ['amber-1', 'amber-2'] },
  { id: 'task-blue', results: ['blue-1', 'blue-2'] },
];

export function createApp() {
  let state = { page: 'detail', objectId: 'item-7', scroll: 184, sheet: null, taskId: null, resultId: null };
  return {
    read: () => structuredClone(state),
    dispatch(action) {
      if (action.type === 'completion-view') {
        state = { ...state, page: 'operations', taskId: null, resultId: null };
      } else if (action.type === 'task-view') {
        const task = tasks.find(item => item.id === action.taskId);
        if (!task) throw new Error('任务不存在');
        state = { ...state, page: 'operations', taskId: null, resultId: null };
      } else if (action.type === 'generate') {
        state = { ...state, page: 'generation', sheet: 'generation' };
      } else if (action.type === 'close') {
        state = { ...state, page: 'detail', sheet: null, scroll: 0 };
      } else {
        throw new Error(`未知动作：${action.type}`);
      }
      return this.read();
    },
  };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const app = createApp();
  const operations = JSON.parse(process.argv[2] ?? '[]');
  console.log(JSON.stringify({ initial: app.read(), states: operations.map(action => app.dispatch(action)) }, null, 2));
}
