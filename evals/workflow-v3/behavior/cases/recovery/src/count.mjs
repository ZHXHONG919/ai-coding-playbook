export function completedCount(tasks) {
  return tasks.filter(task => task.state === 'done').length;
}
