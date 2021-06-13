import 'dart:html';

import 'package:chatapp/subject.dart';
import 'package:chatapp/utils.dart';

import './view.dart';
import '../router.dart';

class RoomView extends View {
  RoomView(this.params)
      : _contents = DocumentFragment(),
        _subject = Subject(params['username']) {
    onEnter(_contents);
  }

  final Subject _subject;
  final DocumentFragment _contents;

  final Map params;

  late DivElement chatBox;
  late DivElement chatText;
  late InputElement messageField;
  late ButtonElement sendBtn;
  late ButtonElement leaveBtn;

  @override
  void onExit() {
    super.onExit();

    _subject.close();
    router.goToView('/');
  }

  @override
  void prepareContent() {
    _contents.innerHtml = ''' 
      <div id="chat-room">
        <div class="columns">
  <div class="column is-two-thirds-mobile is-two-thirds-desktop">
    <h1 class="title">Chat room</h1>
  </div>
  <div class="column has-text-right">
    <button
      id="chat-leave-btn"
      class="button is-warning">Leave</button>
       </div>
      </div>
        <div class="tile is-ancestor">
          <div class="tile is-8 is-vertical is-parent">
            <div class="tile is-child box">
              <div id="chat-room-text"></div>
            </div>
            <div class="tile is-child">
              <div class="field has-addons">
                <div class="control is-expanded has-icons-left">
                  <input id="chat-msg-input" class="input is-medium" type="text" placeholder="Enter message" />
                  <span class="icon is-medium is-left">
                    <i class="fas fa-keyboard"></i>
                  </span>
                </div>
                <div class="control">
                  <button id="chat-send-btn" class="button is-medium is-primary">
                    Send&nbsp;&nbsp;&nbsp;
                    <span class="icon is-medium">
                      <i class="fas fa-paper-plane"></i>
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    ''';

    chatBox = _contents.querySelector('#chat-room') as DivElement;
    chatText = chatBox.querySelector('#chat-room-text') as DivElement;
    messageField = chatBox.querySelector('#chat-msg-input') as InputElement;
    sendBtn = chatBox.querySelector('#chat-send-btn') as ButtonElement;
    leaveBtn = chatBox.querySelector('#chat-leave-btn') as ButtonElement;

    super.prepareContent();
  }

  @override
  void addEventListeners() {
    sendBtn.disabled = true;

    _subject.socket.onMessage.listen(_subjectHandler);
    messageField.addEventListener('input', _messageFieldHandler);
    sendBtn.addEventListener('click', _sendHandler);
    leaveBtn.addEventListener('click', _leaveHandler);
  }

  @override
  void removeEventListeners() {
    messageField.removeEventListener('input', _messageFieldHandler);
    sendBtn.removeEventListener('click', _sendHandler);
    leaveBtn.removeEventListener('click', _leaveHandler);
  }

  void _subjectHandler(MessageEvent event) {
    var decode = deserializeMsg(event.data ?? '{}');
    var from = decode['from'];
    var msg = decode['data'];

    var result;

    if (from == '') {
      result = ''' 
        <div class="tags">
          <p class="tag is-light is-normal">$msg</p> 
        </div>
      ''';
    } else {
      result = '''
      <div class="tags has-addons">
          <span class="tag ${from == 'You' ? 'is-primary' : 'is-dark'}">$from said:</span>
          <span class="tag is-light">$msg</span>
        </div>
      ''';
    }

    chatText.appendHtml(result);
  }

  void _messageFieldHandler(Event event) {
    sendBtn.disabled = messageField.value!.isEmpty;
  }

  void _sendHandler(Event event) {
    _subject.send(
        serializeMsg(Actions.ChatMsg, params['username'], messageField.value!));

    messageField
      ..value = ''
      ..focus();
  }

  void _leaveHandler(Event event) => onExit();
}
