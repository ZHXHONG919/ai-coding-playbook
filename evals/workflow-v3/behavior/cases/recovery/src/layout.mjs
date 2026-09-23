export function renderTasks(tasks) {
  return { layout: 'list', items: tasks.map(task => ({ wrapper: 'row', id: task.id })) };
}
