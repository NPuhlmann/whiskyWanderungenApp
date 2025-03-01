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
              return const CircularProgressIndicator();
            } else {
              // Textfelder um Namen und Adresse des Users zu ändern
              return Column(
                children: [
                  Text(AppLocalizations.of(context)!.firstName),
                  TextField(
                    controller: TextEditingController(text: widget.viewModel.profile.first_name),
                    onChanged: (value) {
                      widget.viewModel.profile.first_name = value;
                    },
                  ),
                  Text(AppLocalizations.of(context)!.lastName),
                  TextField(
                    controller: TextEditingController(text: widget.viewModel.profile.last_name),
                    onChanged: (value) {
                      widget.viewModel.profile.last_name = value;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.viewModel.updateProfile(widget.viewModel.profile);
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              );
            }

          }
      ),
    );
  }
}
