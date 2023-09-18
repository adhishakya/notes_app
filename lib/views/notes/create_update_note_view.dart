import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/note_service.dart';
import 'package:notes_app/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
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

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
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
        actions: [
          IconButton(
            onPressed: () {
              _setupTextControllerListener();
              Navigator.of(context).pop(context);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                        ),
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
