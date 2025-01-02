import 'package:flutter/material.dart';
import 'package:whisky_hikes/UI/profile/profile_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.viewModel});

  final ProfilePageViewModel viewModel;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.viewModel.loadProfile();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        actions: [
          IconButton(
            onPressed: () {
              widget.viewModel.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final String firstName;
            if (widget.viewModel.profile.first_name == "") {
              firstName = "Kein Name";
            } else {
              firstName = widget.viewModel.profile.first_name;
            }
            return SafeArea(
                child: Center(
                  child: Text("First Name: $firstName"),
                )
            );
          }
      ),
    );
  }
}
