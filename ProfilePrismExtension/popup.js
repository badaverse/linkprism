// Localize static text
document.querySelectorAll('[data-i18n]').forEach(el => {
  el.textContent = chrome.i18n.getMessage(el.dataset.i18n);
});

const textarea = document.getElementById('domains');
const savedEl = document.getElementById('saved');

// Load saved domains
chrome.storage.local.get('domains', (result) => {
  textarea.value = (result.domains || []).join('\n');
});

// Auto-save on input
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
