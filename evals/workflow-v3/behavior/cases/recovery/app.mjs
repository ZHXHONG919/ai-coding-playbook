import { pathToFileURL } from 'node:url';
import { renderTasks } from './src/layout.mjs';
import { completedCount } from './src/count.mjs';
export const tasks = [
  { id: 'task-amber', state: 'done' },
  { id: 'task-blue', state: 'queued' },
  { id: 'task-coral', state: 'done' },
];
export function inspect() {
  return { ...renderTasks(tasks), completed: completedCount(tasks) };
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) console.log(JSON.stringify(inspect(), null, 2));
