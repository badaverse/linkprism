// ProfileRouter Chrome Extension - Content Script
// 설정된 도메인의 링크를 클릭하면 ProfileRouter 앱으로 라우팅합니다.

let domains = [];

// 도메인 목록 로드
chrome.storage.local.get('domains', (result) => {
  domains = result.domains || [];
});

// 스토리지 변경 감지
chrome.storage.onChanged.addListener((changes) => {
  if (changes.domains) {
    domains = changes.domains.newValue || [];
  }
});

function shouldRoute(host) {
  return domains.some(
    (d) => host === d || host.endsWith('.' + d)
  );
}

function handleLinkClick(e) {
  if (e.defaultPrevented) return;

  const link = e.target.closest('a[href]');
  if (!link) return;

  const url = link.href;
  if (!url.startsWith('http://') && !url.startsWith('https://')) return;

  try {
    const host = new URL(url).hostname;

    // 현재 페이지와 같은 도메인이면 무시 (사이트 내 이동)
    if (host === location.hostname) return;

    if (shouldRoute(host)) {
      e.preventDefault();
      e.stopPropagation();
      chrome.runtime.sendMessage({ type: 'openViaProfileRouter', url });
    }
  } catch {}
}

document.addEventListener('click', handleLinkClick, true);
document.addEventListener('auxclick', (e) => {
  if (e.button === 1) handleLinkClick(e);
}, true);
