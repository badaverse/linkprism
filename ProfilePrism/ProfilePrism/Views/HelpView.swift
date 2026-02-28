import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hostPatternSection()
                Divider()
                regexPatternSection()
                Divider()
                askFeatureSection()
                Divider()
                chromeProfileDirectorySection()
                Divider()
                chromeExtensionSection()
            }
            .padding(24)
        }
        .frame(minWidth: 480, minHeight: 400)
    }

    // MARK: - 호스트 패턴 매칭

    private func hostPatternSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("호스트 패턴 매칭")
                .font(.headline)

            Text("규칙은 위에서 아래로 순서대로 평가되며, 첫 번째로 일치하는 규칙이 적용됩니다.")
                .font(.body)

            Text("정확한 매칭")
                .font(.subheadline)
                .bold()

            Text("호스트명이 정확히 일치할 때 매칭됩니다.")
                .font(.body)

            Text("atlassian.net")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("와일드카드 매칭")
                .font(.subheadline)
                .bold()

            Text("*를 사용하여 서브도메인을 포함한 매칭이 가능합니다.")
                .font(.body)

            Text("*.atlassian.net")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("이 패턴은 jira.atlassian.net, confluence.atlassian.net 등 모든 서브도메인에 매칭됩니다.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 정규식 패턴

    private func regexPatternSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("정규식 패턴")
                .font(.headline)

            Text("NSRegularExpression을 사용한 정규식 패턴을 지원합니다. 정규식은 호스트명에 대해서만 매칭됩니다.")
                .font(.body)

            Text("예시:")
                .font(.body)
                .bold()

            Text(".*\\.corp\\.example\\.com")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("이 패턴은 corp.example.com의 모든 서브도메인에 매칭됩니다.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 물어보기 기능

    private func askFeatureSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("물어보기 기능")
                .font(.headline)

            Text("규칙의 동작을 \"물어보기\"로 설정하면, 해당 URL을 열 때 프로필 선택 창이 표시됩니다.")
                .font(.body)

            Text("여러 컨텍스트에서 사용하는 도메인(예: GitHub, Google Docs 등)에 유용합니다. 매번 어떤 프로필로 열지 직접 선택할 수 있습니다.")
                .font(.body)
        }
    }

    // MARK: - Chrome 프로필 디렉토리 찾기

    private func chromeProfileDirectorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chrome 프로필 디렉토리 찾기")
                .font(.headline)

            Text("Chrome 프로필 디렉토리는 ProfilePrism이 자동으로 감지합니다. 수동으로 확인하려면:")
                .font(.body)

            VStack(alignment: .leading, spacing: 4) {
                Text("1. Chrome 주소창에 아래 주소를 입력합니다:")
                    .font(.body)

                Text("chrome://version")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)

                Text("2. \"프로필 경로\" 항목에서 마지막 폴더 이름이 프로필 디렉토리입니다.")
                    .font(.body)

                Text("예: /Users/username/Library/Application Support/Google/Chrome/Profile 1")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)

                Text("위 경로에서 \"Profile 1\"이 프로필 디렉토리 이름입니다.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Chrome 확장 프로그램

    private func chromeExtensionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chrome 확장 프로그램")
                .font(.headline)

            Text("Chrome은 내부적으로 링크 클릭을 직접 처리하기 때문에, macOS 기본 브라우저 설정만으로는 Chrome 내부에서 클릭한 링크를 ProfilePrism으로 전달할 수 없습니다.")
                .font(.body)

            Text("확장 프로그램이 필요한 이유")
                .font(.subheadline)
                .bold()

            Text("Chrome 확장 프로그램은 Chrome 내부에서 클릭한 링크를 가로채어 profileprism:// 스킴을 통해 ProfilePrism으로 전달합니다.")
                .font(.body)

            Text("profileprism://route?url=<encoded_url>")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("설치 방법")
                .font(.subheadline)
                .bold()

            VStack(alignment: .leading, spacing: 4) {
                Text("1. Chrome에서 chrome://extensions 페이지를 엽니다.")
                    .font(.body)
                Text("2. \"개발자 모드\"를 활성화합니다.")
                    .font(.body)
                Text("3. \"압축해제된 확장 프로그램을 로드합니다\" 버튼을 클릭합니다.")
                    .font(.body)
                Text("4. ProfilePrism 확장 프로그램 폴더를 선택합니다.")
                    .font(.body)
            }
        }
    }
}

#Preview {
    HelpView()
}
