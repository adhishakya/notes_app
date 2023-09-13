import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/note_service.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      minLeadingWidth: -5,
                      horizontalTitleGap: 10,
                      title: Text(
                        "Logout",
                        style: TextStyle(fontSize: 14),
                      ),
                      dense: true,
                    )),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final note = allNotes[index];
                            return ListTile(
                              title: Column(
                                children: [
                                  Text(
                                    note.title,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    note.text,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
        future: _notesService.getOrCreateUser(email: userEmail),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 16),
        child: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Logout?"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Confirm"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
