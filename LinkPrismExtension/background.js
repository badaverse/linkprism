// LinkPrism Chrome Extension - Background Service Worker
const API_URL = 'http://127.0.0.1:19384/rules';
const POLL_INTERVAL = 30_000;

let cachedRules = [];
let currentProfile = null;

async function sync() {
  // 서버에서 rules + profiles 가져오기
  let data;
  try {
    const res = await fetch(API_URL);
    data = await res.json();
    cachedRules = data.rules || [];
  } catch {
    return; // 앱 미실행
  }

  // chrome.identity 자동 감지
  try {
    const userInfo = await chrome.identity.getProfileUserInfo({ accountStatus: 'ANY' });
    if (userInfo.email) {
      const match = (data.profiles || []).find(p => p.email === userInfo.email);
      if (match) {
        currentProfile = match.directory;
        return;
      }
    }
  } catch {}

  // fallback: 저장된 프로필
  const stored = await chrome.storage.local.get('profileDir');
  if (stored.profileDir) {
    currentProfile = stored.profileDir;
  }
}

async function poll() {
  await sync();
  setTimeout(poll, POLL_INTERVAL);
}
poll();

// storage 변경 감지 (popup에서 수동 선택 시)
chrome.storage.onChanged.addListener((changes) => {
  if (changes.profileDir) {
    currentProfile = changes.profileDir.newValue || null;
  }
});

// 메시지 처리
chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg.type === 'getRulesAndProfile') {
    if (cachedRules.length) {
      sendResponse({ rules: cachedRules, currentProfile });
    } else {
      sync().then(() => sendResponse({ rules: cachedRules, currentProfile }));
      return true;
    }
  }

  if (msg.type === 'forceSync') {
    sync().then(() => sendResponse({ rules: cachedRules, currentProfile }));
    return true;
  }
});
