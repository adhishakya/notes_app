import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/note_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _titleController = TextEditingController();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text;
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      title: title,
      text: text,
    );
  }

  void _setupTextControllerListener() async {
    _titleController.removeListener(_textControllerListener);
    _titleController.addListener(_textControllerListener);
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_titleController.text.isEmpty &&
        _textController.text.isEmpty &&
        note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _titleController.text;
    final text = _textController.text;
    if (title.isNotEmpty && text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        title: title,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Note"),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.only(left: 12, top: 18),
                child: Column(
                  children: [
                    SizedBox(
                      width: 360,
                      child: TextField(
                        controller: _titleController,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Title",
                        ),
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 360,
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Start typing your note...",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
