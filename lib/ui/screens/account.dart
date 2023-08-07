import 'package:butler/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          authProvider.user != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                          height: 150,
                          width: 150,
                          child: CachedNetworkImage(
                            imageUrl: authProvider.user!.photoURL!,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerTheme.color,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerTheme.color,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0)),
                              ),
                              child: const Center(
                                child: Icon(Icons.account_circle,
                                    color: Colors.grey),
                              ),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        authProvider.user!.displayName ?? "",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        authProvider.user!.phoneNumber ?? "",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.signOut();
                      },
                      child: Text(
                        "log out",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.deleteUser();
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        "Delete account",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
