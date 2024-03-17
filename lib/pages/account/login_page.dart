import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:study_buddy/components/buttons/rounded_button.dart';
import 'package:study_buddy/components/dialogs/create_group.dart';
import 'package:study_buddy/components/textfields/rounded_textfield.dart';
import 'package:study_buddy/pages/account/forgot_password.dart';
import 'package:study_buddy/structure/auth/auth_service.dart';

class LoginPage extends StatelessWidget {
  // on Tap
  final void Function()? onTap;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final AuthService _authService = AuthService();
  LoginPage({
    super.key,
    required this.onTap,
  });

  //login with Google
  void signInWithGoogle(BuildContext context) async {
    await _authService.signInWithGoogle();
  }

  void register() {}
  // login method
  void login(BuildContext context) async {
    //try login
    try {
      await _authService.signInWithEmailPassword(
        _emailController.text,
        _pwController.text,
      );
    } catch (e) {
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return const CreateGroupChatDialog(
                confirm: null,
                content:
                    "There was an error processing your information. Kindly try again.",
                title: "Failed",
                type: "Okay");
          });
    }
    // catch any errors
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: Container(
            alignment: Alignment.center,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Study Buddy",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 40),
                    ),
                    Text(
                      "Find study groups and tutors easily",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    RoundedTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: _emailController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    RoundedTextField(
                      hintText: "Password",
                      controller: _pwController,
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const ForgotPasswordPage();
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RoundedButton(
                        text: "Sign in",
                        onTap: () => login(context),
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        textcolor: Theme.of(context).colorScheme.background),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Divider(
                                color: Theme.of(context).colorScheme.primary,
                                thickness: 1,
                              ),
                            ),
                          ),
                          Text(
                            "or continue with",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Divider(
                                color: Theme.of(context).colorScheme.primary,
                                thickness: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () => signInWithGoogle(context),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/google-color_svgrepo.com.svg',
                                height: 20,
                                width: 20,
                              ),
                              const Expanded(
                                child: Text(
                                  "Google",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12)),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: onTap,
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
