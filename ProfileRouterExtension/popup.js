const textarea = document.getElementById('domains');
const savedEl = document.getElementById('saved');

// 저장된 도메인 로드
chrome.storage.local.get('domains', (result) => {
  textarea.value = (result.domains || []).join('\n');
});

// 입력 시 자동 저장
let saveTimer;
textarea.addEventListener('input', () => {
  clearTimeout(saveTimer);
  saveTimer = setTimeout(() => {
    const domains = textarea.value
      .split('\n')
      .map((d) => d.trim().toLowerCase())
      .filter(Boolean);
    chrome.storage.local.set({ domains });

    savedEl.classList.add('show');
    setTimeout(() => savedEl.classList.remove('show'), 1500);
  }, 300);
});
