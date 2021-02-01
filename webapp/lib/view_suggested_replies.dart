part of view;

class SuggestedRepliesConfigurationPage extends ConfigurationPage {
  SelectElement _replyCategories;
  DivElement _suggestedRepliesContainer;

  Map<String, SuggestedReplyGroupView> groups = {};

  SuggestedRepliesConfigurationPage() : super() {
    _configurationTitle.text = 'What do you want to say?';

    _replyCategories = new SelectElement();
    _replyCategories.onChange.listen(
        (_) => controller.command(controller.UIAction.changeSuggestedRepliesCategory, new controller.SuggestedRepliesCategoryData(_replyCategories.value)));
    _configurationContent.append(_replyCategories);

    _suggestedRepliesContainer = new DivElement();
    _configurationContent.append(_suggestedRepliesContainer);

    var addButton = new Button(ButtonType.add,
        hoverText: 'Add a new group of suggested replies', onClick: (event) => controller.command(controller.UIAction.addSuggestedReplyGroup));
    addButton.parent = _configurationContent;
  }

  void addReplyGroup(String id, SuggestedReplyGroupView suggestedReplyGroupView) {
    _suggestedRepliesContainer.append(suggestedReplyGroupView.renderElement);
    groups[id] = suggestedReplyGroupView;
  }

  void removeReplyGroup(String id) {
    groups[id].renderElement.remove();
    groups.remove(id);
  }

  set selectedCategory(String category) {
    int index = _replyCategories.children.indexWhere((Element option) => (option as OptionElement).value == category);
    if (index == -1) {
      // Couldn't find category in list of suggested replies category, using first
      _replyCategories.selectedIndex = 0;
      controller.command(controller.UIAction.changeSuggestedRepliesCategory, new controller.SuggestedRepliesCategoryData(_replyCategories.value));
      return;
    }
    _replyCategories.selectedIndex = index;
  }

  set categories(List<String> categories) {
    _replyCategories.children.clear();
    for (var category in categories) {
      _replyCategories.append(new OptionElement()
        ..value = category
        ..text = category);
    }
  }

  void clear() {
    int repliesNo = _suggestedRepliesContainer.children.length;
    for (int i = 0; i < repliesNo; i++) {
      _suggestedRepliesContainer.firstChild.remove();
    }
    assert(_suggestedRepliesContainer.children.length == 0);
    groups.clear();
  }
}

class SuggestedReplyGroupView {
  DivElement _suggestedRepliesGroupElement;
  DivElement _suggestedRepliesContainer;
  SpanElement _title;

  Map<String, SuggestedReplyView> replies = {};

  SuggestedReplyGroupView(String id, String name) {
    _suggestedRepliesGroupElement = new DivElement()..classes.add('suggested-replies-group');
    var removeButton = new Button(ButtonType.remove, hoverText: 'Remove suggested replies group', onClick: (_) {
      var removeWarningModal;
      removeWarningModal = new InlineOverlayModal('Are you sure you want to remove this group?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeSuggestedReplyGroup, new controller.SuggestedReplyGroupData(id))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => removeWarningModal.remove()),
      ]);
      removeWarningModal.parent = _suggestedRepliesGroupElement;
    });
    removeButton.parent = _suggestedRepliesGroupElement;

    _title = new SpanElement()
      ..classes.add('suggested-replies-group__title')
      ..text = name
      ..title = '<group name>'
      ..contentEditable = 'true'
      ..onBlur.listen((_) => controller.command(
          controller.UIAction.updateSuggestedReplyGroup, new controller.SuggestedReplyGroupData(id, groupName: name, newGroupName: _title.text)));
    _suggestedRepliesGroupElement.append(_title);

    _suggestedRepliesContainer = new DivElement()..classes.add('suggested-reply-container');
    _suggestedRepliesGroupElement.append(_suggestedRepliesContainer);

    var addButton = new Button(ButtonType.add,
        hoverText: 'Add new suggested reply',
        onClick: (_) => controller.command(controller.UIAction.addSuggestedReply, new controller.SuggestedReplyData(null, groupId: id)));
    addButton.parent = _suggestedRepliesGroupElement;
  }

  Element get renderElement => _suggestedRepliesGroupElement;

  void set name(String name) => _title.text = name;

  void addReply(String id, SuggestedReplyView suggestedReplyView) {
    _suggestedRepliesContainer.append(suggestedReplyView.renderElement);
    replies[id] = suggestedReplyView;
  }

  void removeReply(String id) {
    replies[id].renderElement.remove();
    replies.remove(id);
  }
}

class SuggestedReplyView {
  Element _suggestedReplyElement;

  SuggestedReplyView(String id, String text, String translation) {
    _suggestedReplyElement = new DivElement()
      ..classes.add('suggested-reply')
      ..dataset['id'] = '$id';

    var removeButton = new Button(ButtonType.remove, hoverText: 'Remove suggested reply', onClick: (_) {
      var removeWarningModal;
      removeWarningModal = new InlineOverlayModal('Are you sure you want to remove this reply?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeSuggestedReply, new controller.SuggestedReplyData(id))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => removeWarningModal.remove()),
      ]);
      removeWarningModal.parent = _suggestedReplyElement;
    });
    removeButton.parent = _suggestedReplyElement;

    var textView = new SuggestedReplyMessageView(
        0, text, (index, text) => controller.command(controller.UIAction.updateSuggestedReply, new controller.SuggestedReplyData(id, text: text)));
    var translationView = new SuggestedReplyMessageView(0, translation,
        (index, translation) => controller.command(controller.UIAction.updateSuggestedReply, new controller.SuggestedReplyData(id, translation: translation)));
    _suggestedReplyElement..append(textView.renderElement)..append(translationView.renderElement);
    _makeSuggestedReplyMessageViewTextareasSynchronisable([textView, translationView]);
  }

  Element get renderElement => _suggestedReplyElement;
}

class SuggestedReplyMessageView {
  Element _suggestedReplyMessageElement;
  TextAreaElement _suggestedReplyText;
  Function onUpdateSuggestedReplyCallback;
  Function onTextareaHeightChangeCallback;

  SuggestedReplyMessageView(int index, String suggestedReply, this.onUpdateSuggestedReplyCallback) {
    _suggestedReplyMessageElement = new DivElement()..classes.add('suggested-reply-language');

    var suggestedReplyCounter = new SpanElement()
      ..classes.add('suggested-reply-language__text-count')
      ..classes.toggle('suggested-reply-language__text-count--alert', suggestedReply.length > 160)
      ..text = '${suggestedReply.length}/160';

    _suggestedReplyText = new TextAreaElement()
      ..classes.add('suggested-reply-language__text')
      ..classes.toggle('suggested-reply-language__text--alert', suggestedReply.length > 160)
      ..text = suggestedReply != null ? suggestedReply : ''
      ..contentEditable = 'true'
      ..dataset['index'] = '$index'
      ..onBlur.listen((event) => onUpdateSuggestedReplyCallback(index, (event.target as TextAreaElement).value))
      ..onInput.listen((event) {
        int count = _suggestedReplyText.value.split('').length;
        suggestedReplyCounter.text = '${count}/160';
        _suggestedReplyText.classes.toggle('suggested-reply-language__text--alert', count > 160);
        suggestedReplyCounter.classes.toggle('suggested-reply-language__text-count--alert', count > 160);
        _handleTextareaHeightChange();
      });

    _suggestedReplyMessageElement..append(_suggestedReplyText)..append(suggestedReplyCounter);
    finaliseRenderAsync();
  }

  Element get renderElement => _suggestedReplyMessageElement;

  void set textareaHeight(int height) => _suggestedReplyText.style.height = '${height - 6}px';

  /// Returns the height of the content text in the textarea element.
  int get textareaScrollHeight {
    var height = _suggestedReplyText.style.height;
    _suggestedReplyText.style.height = '0';
    var scrollHeight = _suggestedReplyText.scrollHeight;
    _suggestedReplyText.style.height = height;
    return scrollHeight;
  }

  /// This method reports the height of the content text (if the callback is set).
  void _handleTextareaHeightChange() {
    if (onTextareaHeightChangeCallback == null) return;
    onTextareaHeightChangeCallback(textareaScrollHeight);
  }

  /// The response view is added to the DOM at some later point, outside this class.
  /// This method periodically polls until the element has been added to the DOM (height > 0)
  /// and then triggers the first [_handleTextareaHeightChange] so that the parent can
  /// synchronise the height between this reply and it's sibling(s).
  void finaliseRenderAsync() {
    Timer.periodic(new Duration(milliseconds: 10), (timer) {
      if (_suggestedReplyText.scrollHeight == 0) return;
      _handleTextareaHeightChange();
      timer.cancel();
    });
  }
}

_makeSuggestedReplyMessageViewTextareasSynchronisable(List<SuggestedReplyMessageView> suggestedReplyViews) {
  var onTextareaHeightChangeCallback = (int height) {
    var maxHeight = height;
    for (var responseView in suggestedReplyViews) {
      var textareaScrollHeight = responseView.textareaScrollHeight;
      if (textareaScrollHeight > maxHeight) {
        maxHeight = textareaScrollHeight;
      }
    }
    for (var responseView in suggestedReplyViews) {
      responseView.textareaHeight = maxHeight;
    }
  };

  for (var responseView in suggestedReplyViews) {
    responseView.onTextareaHeightChangeCallback = onTextareaHeightChangeCallback;
  }
}
