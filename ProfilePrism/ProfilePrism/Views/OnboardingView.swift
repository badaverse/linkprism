import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    let onComplete: () -> Void
    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch currentStep {
                case 0: step1Introduction
                case 1: step2DefaultBrowser
                case 2: step3ChromeExtension
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)

            Divider()

            HStack {
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Circle()
                            .fill(i == currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 7, height: 7)
                    }
                }
                Spacer()
                if currentStep > 0 {
                    Button("이전") { withAnimation { currentStep -= 1 } }
                }
                if currentStep < totalSteps - 1 {
                    Button("다음") { withAnimation { currentStep += 1 } }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("시작하기") { onComplete() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(width: 480, height: 380)
    }

    private var step1Introduction: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)
            Text("ProfilePrism에 오신 것을 환영합니다")
                .font(.title2.bold())
            Text("URL을 자동으로 올바른 Chrome 프로필로\n라우팅하는 macOS 메뉴바 앱입니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "globe", text: "도메인별 Chrome 프로필 자동 선택")
                featureRow(icon: "arrow.triangle.branch", text: "호스트, 와일드카드, 정규식 패턴 지원")
                featureRow(icon: "questionmark.circle", text: "\"물어보기\" 모드로 매번 프로필 선택 가능")
            }
            .padding(.top, 8)
        }
    }

    private var step2DefaultBrowser: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("기본 브라우저로 설정")
                .font(.title2.bold())
            Text("ProfilePrism이 URL을 받으려면\n기본 웹 브라우저로 설정해야 합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("시스템 설정 열기") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Text("시스템 설정 → 데스크탑 및 Dock → 기본 웹 브라우저\n에서 \"ProfilePrism\"을 선택하세요.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var step3ChromeExtension: some View {
        VStack(spacing: 16) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Chrome 확장 프로그램")
                .font(.title2.bold())
            Text("Chrome 내부에서 클릭한 링크는 기본 브라우저를\n거치지 않아 ProfilePrism이 개입할 수 없습니다.\n확장 프로그램을 설치하면 이 문제를 해결할 수 있습니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)
            VStack(alignment: .leading, spacing: 8) {
                stepRow(number: 1, text: "Chrome에서 chrome://extensions 열기")
                stepRow(number: 2, text: "\"개발자 모드\" 활성화")
                stepRow(number: 3, text: "\"압축해제된 확장 프로그램을 로드합니다\" 클릭")
                stepRow(number: 4, text: "ProfilePrismExtension 폴더 선택")
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.08)))
            Text("확장 프로그램은 나중에 설치해도 됩니다.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text).font(.callout)
        }
    }

    private func stepRow(number: Int, text: String) -> some View {
        HStack(spacing: 10) {
            Text("\(number)")
                .font(.caption.bold())
                .frame(width: 20, height: 20)
                .background(Circle().fill(.blue.opacity(0.15)))
                .foregroundStyle(.blue)
            Text(text).font(.callout)
        }
    }
}
