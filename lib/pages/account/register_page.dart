import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:study_buddy/components/dialogs/create_group.dart';
import 'package:study_buddy/components/textfields/rounded_textfield.dart';
import 'package:study_buddy/components/textfields/rounded_textfield_suffix.dart';
import 'package:study_buddy/error/login_response.dart';
import 'package:study_buddy/structure/auth/auth_service.dart';
import 'package:study_buddy/structure/providers/register_provider.dart';
import 'package:study_buddy/structure/providers/university_provider.dart';

class RegisterPage extends ConsumerWidget {
  final void Function()? onTap;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  RegisterPage({
    super.key,
    required this.onTap,
  });

  // register

  Future<void> register(
    BuildContext context,
    String universityName,
    String universityId,
    String emailDomain,
    List<String> domains,
  ) async {
    // get auth service
    final auth = AuthService();
    if (_pwController.text.isNotEmpty &&
        _confirmPwController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        universityName.isNotEmpty &&
        universityId.isNotEmpty) {
      // password match => create user
      if (_pwController.text == _confirmPwController.text) {
        LoginResponse response = await auth.signUpWithEmailPassword(
          context,
          _emailController.text,
          _pwController.text,
          _firstNameController.text,
          _lastNameController.text,
          universityName,
          universityId,
          emailDomain,
          domains,
        );
        if (!response.isSuccess) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(response.message ?? 'Unknown error'),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('User created successfully'),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => const CreateGroupChatDialog(
            confirm: null,
            content: "Password does not match.",
            title: "Failed",
            type: "Okay",
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const CreateGroupChatDialog(
          confirm: null,
          content: "Incomplete information.",
          title: "Failed",
          type: "Okay",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useUniversityProvider = ref.watch(universityProvider);
    final controller = PageController();
    final lastPage = ref.watch(lastPageProvider);
    final firstPage = ref.watch(firstPageProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final domains = ref.watch(universityDomainNamesProvider).value;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Create Account"),
            ),
            body: PageView(
              controller: controller,
              onPageChanged: (value) {
                if (value == 2) {
                  ref.read(lastPageProvider.notifier).update((state) => true);
                } else {
                  ref.read(lastPageProvider.notifier).update((state) => false);
                }
                if (value == 0) {
                  ref.read(firstPageProvider.notifier).update((state) => true);
                } else {
                  ref.read(firstPageProvider.notifier).update((state) => false);
                }
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "What university are you from?",
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SearchBar(
                        hintText: "Search",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      useUniversityProvider.when(
                        data: (university) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: university.length,
                              itemBuilder: (context, index) {
                                final universityItem = university[index];
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(selectedIndexProvider.notifier)
                                        .update((state) => index);
                                    ref
                                        .read(emailDomainProvider.notifier)
                                        .state = universityItem.emailIndicator;

                                    ref
                                        .read(universityNameProvider.notifier)
                                        .state = universityItem.uniName;

                                    ref
                                        .read(universityIdProvider.notifier)
                                        .state = universityItem.uniId;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(universityItem.logo),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(universityItem.uniName),
                                        ),
                                        Radio(
                                            value: index,
                                            groupValue: selectedIndex,
                                            focusColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            onChanged: (number) {
                                              ref
                                                  .read(selectedIndexProvider
                                                      .notifier)
                                                  .update(
                                                      (state) => number as int);

                                              ref
                                                      .read(emailDomainProvider
                                                          .notifier)
                                                      .state =
                                                  universityItem.emailIndicator;
                                              ref
                                                      .read(
                                                          universityNameProvider
                                                              .notifier)
                                                      .state =
                                                  universityItem.uniName;

                                              ref
                                                  .read(universityIdProvider
                                                      .notifier)
                                                  .state = universityItem.uniId;
                                            })
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return Center(
                            child: Text('Error: $error'),
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  alignment: Alignment.topLeft,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "What is your name?",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          RoundedTextField(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            hintText: "First Name",
                            obscureText: false,
                            controller: _firstNameController,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          RoundedTextField(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            hintText: "Last Name",
                            obscureText: false,
                            controller: _lastNameController,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "What is your email?",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RoundedTextFieldSuffix(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        hintText: "Email",
                        obscureText: false,
                        controller: _emailController,
                        suffixText: ref.watch(emailDomainProvider),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "How about your password?",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RoundedTextField(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          hintText: "Password",
                          obscureText: true,
                          controller: _pwController),
                      const SizedBox(
                        height: 10,
                      ),
                      RoundedTextField(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          hintText: "Confirm password",
                          obscureText: true,
                          controller: _confirmPwController),
                    ],
                  ),
                ),
              ],
            ),
            bottomSheet: SizedBox(
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        dotColor: Theme.of(context).colorScheme.secondary,
                        activeDotColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      onDotClicked: (index) => controller.animateToPage(index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: firstPage
                            ? null
                            : () => controller.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                        child: firstPage ? const Text('') : const Text("Back"),
                      ),
                      Row(
                        children: [
                          Text("Already have an account?",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12)),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: onTap,
                            child: Text(
                              "Login now",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: lastPage
                            ? () => register(
                                context,
                                ref.watch(universityNameProvider),
                                ref.watch(universityIdProvider),
                                ref.watch(emailDomainProvider),
                                domains!)
                            : () => controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut),
                        child: lastPage
                            ? Text(
                                "Verify",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                ),
                              )
                            : const Text("Next"),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
