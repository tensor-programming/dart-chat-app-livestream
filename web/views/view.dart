import 'dart:html';

abstract class View {
  void onEnter(DocumentFragment _contents) {
    prepareContent();
    render(_contents);
  }

  void onExit() {
    removeEventListeners();
  }

  void prepareContent() {
    addEventListeners();
  }

  void render(DocumentFragment _contents) {
    querySelector('#app')
      ?..innerHtml = ''
      ..append(_contents);
  }

  void addEventListeners();
  void removeEventListeners();
}
