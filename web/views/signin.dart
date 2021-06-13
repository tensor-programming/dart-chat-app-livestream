import 'dart:html';

import './view.dart';
import '../router.dart';

class SignInView extends View {
  SignInView() : _contents = DocumentFragment() {
    onEnter(_contents);
  }

  final DocumentFragment _contents;
  late DivElement signInBox;
  late ParagraphElement validationBox;
  late InputElement nameField;
  late ButtonElement submitBtn;
  late HttpRequest _response;

  @override
  void onExit() {
    super.onExit();
    router.goToView('/chat-room', params: {'username': _response.responseText});
  }

  @override
  void prepareContent() {
    _contents.innerHtml = '''
      <div id="chat-sign-in">
      <h1 class="title">Dart Chat App &#128761;</h1>
      <div class="columns">
        <div class="column is-6">
          <div class="field">
            <label class="label">Please enter your name</label>
            <div class="control is-expanded has-icons-left">
              <input class="input is-medium" type="text" placeholder="Enter your name and hit ENTER" />
              <span class="icon is-medium is-left">
                <i class="fas fa-user"></i>
              </span>
            </div>
            <p class="help is-danger"></p>
          </div>
          <div class="field">
            <div class="control">
              <button class="button is-medium is-primary">
                Join chat
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    ''';

    signInBox = _contents.querySelector('#chat-sign-in') as DivElement;
    validationBox = signInBox.querySelector('p.help') as ParagraphElement;
    nameField = signInBox.querySelector('input[type="text"]') as InputElement;
    submitBtn = signInBox.querySelector('button') as ButtonElement;

    super.prepareContent();
  }

  @override
  void addEventListeners() {
    nameField.addEventListener('input', _inputHandler);
    submitBtn.addEventListener('click', _clickHandler);
  }

  @override
  void removeEventListeners() {
    nameField.removeEventListener('input', _inputHandler);
    submitBtn.removeEventListener('click', _clickHandler);
  }

  void _inputHandler(Event event) {
    if (nameField.value!.trim().isNotEmpty) {
      nameField.classes
        ..removeWhere((name) => name == 'is-danger')
        ..add('is-success');
      validationBox.text = '';
    } else {
      nameField.classes
        ..removeWhere((name) => name == 'is-success')
        ..add('is-danger');
    }
  }

  void _clickHandler(Event event) async {
    if (nameField.value!.trim().isEmpty) {
      submitBtn.classes
        ..removeWhere((name) => name == 'is-success' || name == 'is-danger')
        ..add('is-warning');

      nameField.classes.add('is-danger');

      validationBox.text = 'Please enter your user name!';
      return;
    } else {
      submitBtn.classes
        ..removeWhere((name) => name == 'is-warning' || name == 'is-danger')
        ..add('is-success');
    }

    submitBtn.disabled = true;

    try {
      _response = await HttpRequest.postFormData(
          'http://localhost:9090/signin', {'username': nameField.value ?? ''});

      onExit();
    } catch (e) {
      submitBtn
        ..disabled = false
        ..text = 'Failed to Join. Please try again.';

      submitBtn.classes
        ..removeWhere((name) => name == 'is-success' || name == 'is-warning')
        ..add('is-danger');
    }
  }
}
