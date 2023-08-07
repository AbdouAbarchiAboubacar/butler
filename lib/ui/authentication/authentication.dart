import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/connexion.dart/connectivity_status.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State createState() => _AuthenticationScreenState();
}

//secondRegister
enum FormType { signIn, signUp }

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController intlPhoneNumberController = TextEditingController();

  FormType _formType = FormType.signIn;
  String? _phoneNumber;
  bool callSetStateOnce = false;

  @override
  void initState() {
    super.initState();
  }

  void moveToSignIn() {
    formKey.currentState!.reset();
    FocusScope.of(context).unfocus();
    setState(() {
      _formType = FormType.signIn;
    });
  }

  void moveToSignUp() {
    formKey.currentState!.reset();
    FocusScope.of(context).unfocus();
    setState(() {
      _formType = FormType.signUp;
    });
  }

  //* =======================>   Google Sign In

  googleSignIn(AuthProvider authProvider, FirestoreDatabase firestoreDatabase,
      BuildContext context, ConnectivityStatus connectivity) async {
    if (connectivity == ConnectivityStatus.offline) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.yellow[700],
        duration: const Duration(seconds: 5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(CommunityMaterialIcons.wifi_cancel, color: Colors.black),
            const SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Oops! It looks like you're offline.🌐📶",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.black)),
                ],
              ),
            )
          ],
        ),
      ));
    } else {
      if (_formType == FormType.signUp && _phoneNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.yellow[700],
          duration: const Duration(seconds: 5),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(CommunityMaterialIcons.wifi_cancel,
                  color: Colors.black),
              const SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Please provide a valid phone number to proceed. This information is necessary to complete the action. 📞",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.black)),
                  ],
                ),
              )
            ],
          ),
        ));
      }
      await authProvider.signInWithGoogle(
          context: context, formType: _formType, phoneNumer: _phoneNumber);
    }
  }

  @override
  void dispose() {
    intlPhoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    //
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);

    final connectivity = Provider.of<ConnectivityStatus>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buildInputs(
                      authProvider, firestoreDatabase, context, connectivity) +
                  sumbitButton(
                      authProvider, firestoreDatabase, context, connectivity),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildInputs(
      authProvider, firestoreDatabase, context, connectivity) {
    return [
      Expanded(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: kToolbarHeight,
                    ),
                    Text(
                      _formType == FormType.signUp ? "Sign Up" : "Sign In",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              if (_formType != FormType.signIn) {
                                moveToSignIn();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                                backgroundColor: _formType != FormType.signIn
                                    ? Colors.white
                                    : Colors.blue),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                  color: _formType == FormType.signIn
                                      ? Colors.white
                                      : Colors.blue),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              if (_formType != FormType.signUp) {
                                moveToSignUp();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                                backgroundColor: _formType != FormType.signUp
                                    ? Colors.white
                                    : Colors.blue),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: _formType == FormType.signUp
                                      ? Colors.white
                                      : Colors.blue),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 20, top: 20),
                        child: Image.asset("assets/images/login.png"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    ];
  }

  List<Widget> sumbitButton(
      authProvider, firestoreDatabase, context, connectivity) {
    return [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _formType == FormType.signUp
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InternationalPhoneNumberInput(
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .primary),
                      textFieldController: intlPhoneNumberController,
                      formatInput: false,
                      textStyle: Theme.of(context).textTheme.displaySmall,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputDecoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(12.0),
                          counterText: "",
                          filled: false,
                          focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .primary)),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide:
                                BorderSide(color: Colors.red.withOpacity(0.5)),
                          ),
                          errorStyle: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.red),
                          hintText: "Your phone number",
                          hintStyle: Theme.of(context).textTheme.headlineSmall),
                      onFieldSubmitted: (String value) {},
                      onSaved: (phone) => _phoneNumber = phone.phoneNumber,
                      onInputChanged: (phone) =>
                          _phoneNumber = phone.phoneNumber,
                      onInputValidated: (bool value) {},
                      selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          setSelectorButtonAsPrefixIcon: false,
                          showFlags: false,
                          trailingSpace: false),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              width: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 55,
                  child: Stack(children: [
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          googleSignIn(authProvider, firestoreDatabase, context,
                              connectivity);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return const Color(0xFFde5246);
                            },
                          ),
                          padding: MaterialStateProperty.resolveWith<
                              EdgeInsetsGeometry>(
                            (Set<MaterialState> states) {
                              return const EdgeInsets.all(2);
                            },
                          ),
                          shape:
                              MaterialStateProperty.resolveWith<OutlinedBorder>(
                            (Set<MaterialState> states) {
                              return const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)));
                            },
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(0.5),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Image.asset(
                                "assets/images/google.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Text(
                              "Google",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                    authProvider.status == Status.googleAuthenticating
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                                width: 55,
                                height: 55,
                                child: CircularProgressIndicator(
                                    strokeWidth: 4.0,
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context)
                                            .buttonTheme
                                            .colorScheme!
                                            .primary))),
                          )
                        : Container(),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
