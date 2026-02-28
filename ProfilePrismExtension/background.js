// ProfilePrism Chrome Extension - Background Service Worker
// content script에서 받은 URL을 profilerouter:// 스킴으로 열어줍니다.

chrome.runtime.onMessage.addListener((msg, sender) => {
  if (msg.type === 'openViaProfilePrism') {
    const encoded = encodeURIComponent(msg.url);
    // profilerouter:// 스킴으로 macOS ProfilePrism 앱 호출
    chrome.tabs.update(sender.tab.id, {
      url: `profilerouter://route?url=${encoded}`,
    });
  }
});
