import OmniSegmentKit  // BeBit Tech analytics SDK for user login and registration tracking
import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongCredentials = false
    @State private var isShowingLoader = false

    @Binding var isUserLoggedIn: Bool

    private let defaultUsername = "omnisegment20240101"
    private let defaultPassword = "test"
    private let email = "renee.wei@bebit-tech.com"
    private let regeType = "google"

    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.ignoresSafeArea()
                Circle().scale(1.7).foregroundColor(.white.opacity(0.15))
                Circle().scale(1.35).foregroundColor(.white)
                VStack {
                    Text("Login/Register")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .border(wrongCredentials ? Color.red : Color.clear, width: 2)
                        .foregroundColor(.black)
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .border(wrongCredentials ? Color.red : Color.clear, width: 2)
                        .foregroundColor(.black)
                    HStack {
                        Button("Login") {
                            attemptLogin()
                        }
                        .buttonStyle(PrimaryButtonStyle(isLoading: isShowingLoader))

                        Button("Register") {
                            attemptRegistration()
                        }
                        .buttonStyle(PrimaryButtonStyle(isLoading: isShowingLoader))
                    }
                    .padding()

                    if wrongCredentials {
                        Text("Incorrect username or password")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // Set current page for analytics tracking
                // Page Tracking: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
                OmniSegment.setCurrentPage("Login")
                username = defaultUsername
                password = defaultPassword
            }
        }
    }

    private func attemptLogin() {
        isShowingLoader = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isShowingLoader = false
            if username != "", password == defaultPassword {
                userLoginSuccess()
                // Track successful login event with user ID
                // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#login
                OmniSegment.login(uid: username)
                print("uid is username: \(username)")
            } else {
                wrongCredentials = true
            }
        }
    }

    private func attemptRegistration() {
        isShowingLoader = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isShowingLoader = false

            // Track user registration completion event
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
            var event = OSGEvent.completeRegistration(label: ["regeType": regeType])
            event.location = "RegistrationPage"
            event.locationTitle = "SweaterApp Registration"
            OmniSegment.trackEvent(event)
        }
    }

    private func userLoginSuccess() {
        UserDefaults.standard.set(username, forKey: "userUID")
        isUserLoggedIn = true
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .disabled(isLoading)
            .foregroundColor(.white)
            .frame(width: 140, height: 50)
            .background(isLoading ? Color.gray : Color.blue)
            .cornerRadius(10)
            .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var dummyIsUserLoggedIn = false

    static var previews: some View {
        LoginView(isUserLoggedIn: $dummyIsUserLoggedIn)
    }
}
