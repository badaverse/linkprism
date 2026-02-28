const API_URL = 'http://127.0.0.1:19384/rules';
const statusBox = document.getElementById('statusBox');
const profileSelectEl = document.getElementById('profileSelect');

// i18n
document.querySelectorAll('[data-i18n]').forEach(el => {
  const msg = chrome.i18n.getMessage(el.dataset.i18n);
  if (msg) el.textContent = msg;
});

function showConnected(profileName) {
  statusBox.style.display = 'block';
  statusBox.className = 'status-box connected';
  statusBox.textContent = '';

  const connText = document.createTextNode(chrome.i18n.getMessage('appConnected'));
  statusBox.appendChild(connText);

  if (profileName) {
    statusBox.appendChild(document.createElement('br'));
    const label = document.createTextNode(
      chrome.i18n.getMessage('detectedProfile') + ': '
    );
    statusBox.appendChild(label);
    const name = document.createElement('span');
    name.className = 'profile-name';
    name.textContent = profileName;
    statusBox.appendChild(name);
  }
}

function showProfileSelector(profiles, savedDir) {
  profileSelectEl.style.display = 'block';
  profileSelectEl.textContent = '';

  const heading = document.createElement('h3');
  heading.textContent = chrome.i18n.getMessage('selectProfile');
  profileSelectEl.appendChild(heading);

  profiles.forEach(p => {
    const btn = document.createElement('button');
    btn.className = 'profile-btn';
    if (p.directory === savedDir) btn.classList.add('selected');

    btn.appendChild(document.createTextNode(p.name));

    if (p.email) {
      btn.appendChild(document.createElement('br'));
      const emailSpan = document.createElement('span');
      emailSpan.className = 'email';
      emailSpan.textContent = p.email;
      btn.appendChild(emailSpan);
    }

    btn.addEventListener('click', () => {
      chrome.storage.local.set({ profileDir: p.directory });
      chrome.runtime.sendMessage({ type: 'profileSelected', directory: p.directory });
      profileSelectEl.querySelectorAll('.profile-btn').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      showConnected(p.name);
    });

    profileSelectEl.appendChild(btn);
  });
}

async function showStatus() {
  // 1. chrome.identity 자동 감지
  let userEmail = '';
  try {
    const userInfo = await chrome.identity.getProfileUserInfo({ accountStatus: 'ANY' });
    userEmail = userInfo.email || '';
  } catch {}

  // 2. 서버 연결
  let data = null;
  try {
    const res = await fetch(API_URL);
    data = await res.json();
  } catch {
    statusBox.style.display = 'block';
    statusBox.className = 'status-box disconnected';
    statusBox.textContent = chrome.i18n.getMessage('appDisconnected');
    return;
  }

  const profiles = data.profiles || [];

  // 3. 프로필 매칭: identity → saved → selector
  let matched = null;

  if (userEmail) {
    matched = profiles.find(p => p.email === userEmail);
  }

  if (!matched) {
    const stored = await chrome.storage.local.get('profileDir');
    if (stored.profileDir) {
      matched = profiles.find(p => p.directory === stored.profileDir);
    }
  }

  // 4. 갱신 버튼 표시
  const refreshBtn = document.getElementById('refreshBtn');
  refreshBtn.style.display = 'block';

  refreshBtn.onclick = () => {
    refreshBtn.disabled = true;
    chrome.runtime.sendMessage({ type: 'forceSync' }, () => {
      if (chrome.runtime.lastError) {
        refreshBtn.disabled = false;
        return;
      }
      // popup 전체 새로고침
      statusBox.style.display = 'none';
      profileSelectEl.style.display = 'none';
      refreshBtn.style.display = 'none';
      showStatus();
    });
  };

  if (matched) {
    showConnected(matched.name);
  } else if (profiles.length > 0) {
    showConnected(null);
    showProfileSelector(profiles, null);
  } else {
    showConnected(null);
  }
}

showStatus();
