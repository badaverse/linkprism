// LinkPrism Chrome Extension - Content Script
// macOS 앱에서 규칙을 가져와 매칭되는 cross-domain 링크를 라우팅합니다.
// 현재 프로필과 타겟 프로필이 같으면 정상 내비게이션합니다.

let rules = [];
let currentProfile = null;

function loadData() {
  chrome.runtime.sendMessage({ type: 'getRulesAndProfile' }, (data) => {
    if (chrome.runtime.lastError) return;
    if (data) {
      rules = data.rules || [];
      currentProfile = data.currentProfile || null;
    }
  });
}

loadData();
setInterval(loadData, 30_000);

function matchRule(url) {
  const host = new URL(url).hostname;

  for (const rule of rules) {
    if (rule.patternType === 'host') {
      if (rule.pattern.startsWith('*.')) {
        const base = rule.pattern.slice(2);
        if (host === base || host.endsWith('.' + base)) return rule;
      } else {
        if (host === rule.pattern) return rule;
      }
    } else if (rule.patternType === 'regex') {
      try {
        if (new RegExp(rule.pattern).test(url)) return rule;
      } catch {}
    }
  }
  return null;
}

function handleLinkClick(e) {
  if (e.defaultPrevented) return;

  const link = e.target.closest('a[href]');
  if (!link) return;

  const url = link.href;
  if (!url.startsWith('http://') && !url.startsWith('https://')) return;

  try {
    const host = new URL(url).hostname;
    if (host === location.hostname) return;

    const rule = matchRule(url);
    if (!rule) return; // 규칙 불일치 → 정상 내비게이션

    // 현재 프로필 = 타겟 프로필이면 정상 내비게이션
    if (!rule.shouldAsk && currentProfile === rule.chromeProfile) return;

    e.preventDefault();
    e.stopPropagation();

    const frame = document.createElement('iframe');
    frame.style.display = 'none';
    frame.src = `linkprism://route?url=${encodeURIComponent(url)}`;
    document.body.appendChild(frame);
    setTimeout(() => frame.remove(), 1000);
  } catch {}
}

document.addEventListener('click', handleLinkClick, true);
document.addEventListener('auxclick', (e) => {
  if (e.button === 1) handleLinkClick(e);
}, true);
