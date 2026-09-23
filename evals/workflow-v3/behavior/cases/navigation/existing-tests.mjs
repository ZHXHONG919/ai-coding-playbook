import assert from 'node:assert/strict';
import { createApp } from './app.mjs';
assert.equal(createApp().dispatch({ type: 'completion-view' }).page, 'operations');
assert.equal(createApp().dispatch({ type: 'task-view', taskId: 'task-blue' }).page, 'operations');
assert.equal(createApp().dispatch({ type: 'generate' }).sheet, 'generation');
console.log('已有自测：3 项通过');
