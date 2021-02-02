part of view;

class StandardMessagesConfigurationPage extends ConfigurationPage {
  SelectElement _categories;
  DivElement _standardMessagesContainer;

  Map<String, StandardMessagesGroupView> groups = {};

  StandardMessagesConfigurationPage() : super() {
    _configurationTitle.text = 'What do you want to say?';

    _categories = new SelectElement();
    _categories.onChange.listen(
        (_) => controller.command(controller.UIAction.changeStandardMessagesCategory, new controller.StandardMessagesCategoryData(_categories.value)));
    _configurationContent.append(_categories);

    _standardMessagesContainer = new DivElement();
    _configurationContent.append(_standardMessagesContainer);

    var addButton = new Button(ButtonType.add,
        hoverText: 'Add a new group of standard messages', onClick: (event) => controller.command(controller.UIAction.addStandardMessagesGroup));
    addButton.parent = _configurationContent;
  }

  void addGroup(String id, StandardMessagesGroupView standardMessagesGroupView) {
    _standardMessagesContainer.append(standardMessagesGroupView.renderElement);
    groups[id] = standardMessagesGroupView;
  }

  void removeGroup(String id) {
    groups[id].renderElement.remove();
    groups.remove(id);
  }

  set selectedCategory(String category) {
    int index = _categories.children.indexWhere((Element option) => (option as OptionElement).value == category);
    if (index == -1) {
      // Couldn't find category in list of standard messages category, using first
      _categories.selectedIndex = 0;
      controller.command(controller.UIAction.changeStandardMessagesCategory, new controller.StandardMessagesCategoryData(_categories.value));
      return;
    }
    _categories.selectedIndex = index;
  }

  set categories(List<String> categories) {
    _categories.children.clear();
    for (var category in categories) {
      _categories.append(new OptionElement()
        ..value = category
        ..text = category);
    }
  }

  void clear() {
    int messagesNo = _standardMessagesContainer.children.length;
    for (int i = 0; i < messagesNo; i++) {
      _standardMessagesContainer.firstChild.remove();
    }
    assert(_standardMessagesContainer.children.length == 0);
    groups.clear();
  }
}

class StandardMessagesGroupView {
  DivElement _standardMessagesGroupElement;
  DivElement _standardMessagesContainer;
  SpanElement _title;

  Map<String, StandardMessageView> messagesById = {};

  StandardMessagesGroupView(String id, String name) {
    _standardMessagesGroupElement = new DivElement()..classes.add('standard-messages-group');
    var removeButton = new Button(ButtonType.remove, hoverText: 'Remove standard messages group', onClick: (_) {
      var removeWarningModal;
      removeWarningModal = new InlineOverlayModal('Are you sure you want to remove this group?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeStandardMessagesGroup, new controller.StandardMessagesGroupData(id))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => removeWarningModal.remove()),
      ]);
      removeWarningModal.parent = _standardMessagesGroupElement;
    });
    removeButton.parent = _standardMessagesGroupElement;

    _title = new SpanElement()
      ..classes.add('standard-messages-group__title')
      ..text = name
      ..title = '<group name>'
      ..contentEditable = 'true'
      ..onBlur.listen((_) => controller.command(
          controller.UIAction.updateStandardMessagesGroup, new controller.StandardMessagesGroupData(id, groupName: name, newGroupName: _title.text)));
    _standardMessagesGroupElement.append(_title);

    _standardMessagesContainer = new DivElement()..classes.add('standard-message-container');
    _standardMessagesGroupElement.append(_standardMessagesContainer);

    var addButton = new Button(ButtonType.add,
        hoverText: 'Add new standard message',
        onClick: (_) => controller.command(controller.UIAction.addStandardMessage, new controller.StandardMessageData(null, groupId: id)));
    addButton.parent = _standardMessagesGroupElement;
  }

  Element get renderElement => _standardMessagesGroupElement;

  void set name(String name) => _title.text = name;

  void addMessage(String id, StandardMessageView standardMessageView) {
    _standardMessagesContainer.append(standardMessageView.renderElement);
    messagesById[id] = standardMessageView;
  }

  void removeMessage(String id) {
    messagesById[id].renderElement.remove();
    messagesById.remove(id);
  }
}

class StandardMessageView {
  Element _standardMessageElement;

  StandardMessageView(String id, String text, String translation) {
    _standardMessageElement = new DivElement()
      ..classes.add('standard-message')
      ..dataset['id'] = '$id';

    var removeButton = new Button(ButtonType.remove, hoverText: 'Remove standard message', onClick: (_) {
      var removeWarningModal;
      removeWarningModal = new InlineOverlayModal('Are you sure you want to remove this message?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeStandardMessage, new controller.StandardMessageData(id))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => removeWarningModal.remove()),
      ]);
      removeWarningModal.parent = _standardMessageElement;
    });
    removeButton.parent = _standardMessageElement;

    var textView = new MessageView(
        0, text, (index, text) => controller.command(controller.UIAction.updateStandardMessage, new controller.StandardMessageData(id, text: text)));
    var translationView = new MessageView(0, translation,
        (index, translation) => controller.command(controller.UIAction.updateStandardMessage, new controller.StandardMessageData(id, translation: translation)));
    _standardMessageElement..append(textView.renderElement)..append(translationView.renderElement);
    _makeStandardMessageViewTextareasSynchronisable([textView, translationView]);
  }

  Element get renderElement => _standardMessageElement;
}

class MessageView {
  Element _messageElement;
  TextAreaElement _messageText;
  Function onMessageUpdateCallback;
  Function _onTextareaHeightChangeCallback;

  MessageView(int index, String message, this.onMessageUpdateCallback) {
    _messageElement = new DivElement()..classes.add('message');

    var textLengthIndicator = new SpanElement()
      ..classes.add('message__length-indicator')
      ..classes.toggle('message__length-indicator--alert', message.length > 160)
      ..text = '${message.length}/160';

    _messageText = new TextAreaElement()
      ..classes.add('message__text')
      ..classes.toggle('message__text--alert', message.length > 160)
      ..text = message != null ? message : ''
      ..contentEditable = 'true'
      ..dataset['index'] = '$index'
      ..onBlur.listen((event) => onMessageUpdateCallback(index, (event.target as TextAreaElement).value))
      ..onInput.listen((event) {
        int count = _messageText.value.split('').length;
        textLengthIndicator.text = '${count}/160';
        _messageText.classes.toggle('message__text--alert', count > 160);
        textLengthIndicator.classes.toggle('message__length-indicator--alert', count > 160);
        _handleTextareaHeightChange();
      });

    _messageElement..append(_messageText)..append(textLengthIndicator);
    finaliseRenderAsync();
  }

  Element get renderElement => _messageElement;

  void set textareaHeight(int height) => _messageText.style.height = '${height - 6}px';

  /// Returns the height of the content text in the textarea element.
  int get textareaScrollHeight {
    var height = _messageText.style.height;
    _messageText.style.height = '0';
    var scrollHeight = _messageText.scrollHeight;
    _messageText.style.height = height;
    return scrollHeight;
  }

  /// This method reports the height of the content text (if the callback is set).
  void _handleTextareaHeightChange() {
    if (_onTextareaHeightChangeCallback == null) return;
    _onTextareaHeightChangeCallback(textareaScrollHeight);
  }

  /// The message view is added to the DOM at some later point, outside this class.
  /// This method periodically polls until the element has been added to the DOM (height > 0)
  /// and then triggers the first [_handleTextareaHeightChange] so that the parent can
  /// synchronise the height between this message and its sibling(s).
  void finaliseRenderAsync() {
    Timer.periodic(new Duration(milliseconds: 10), (timer) {
      if (_messageText.scrollHeight == 0) return;
      _handleTextareaHeightChange();
      timer.cancel();
    });
  }
}

_makeStandardMessageViewTextareasSynchronisable(List<MessageView> messageViews) {
  var onTextareaHeightChangeCallback = (int height) {
    var maxHeight = height;
    for (var messageView in messageViews) {
      var textareaScrollHeight = messageView.textareaScrollHeight;
      if (textareaScrollHeight > maxHeight) {
        maxHeight = textareaScrollHeight;
      }
    }
    for (var messageView in messageViews) {
      messageView.textareaHeight = maxHeight;
    }
  };

  for (var messageView in messageViews) {
    messageView._onTextareaHeightChangeCallback = onTextareaHeightChangeCallback;
  }
}
