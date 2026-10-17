// 当前采用覆写：图片区为单组内三行，操作位于每行右侧；不是三张独立卡片。
for (const row of document.querySelectorAll('.images .row')) {
  const button = document.createElement('button'); button.textContent = '选择图片'; row.append(button);
  row.style.display = 'flex'; row.style.alignItems = 'center'; row.style.justifyContent = 'space-between';
}
