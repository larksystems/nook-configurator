part of view;

class TagsConfigurationPage extends ConfigurationPage {
  DivElement _tagsContainer;
  Button addGroupButton;

  Map<String, TagGroupView> groups = {};

  TagsConfigurationPage() : super() {
    _configurationTitle.text = 'How do you want to tag the messages and conversations?';

    _tagsContainer = new DivElement();
    _configurationContent.append(_tagsContainer);

    addGroupButton = new Button(ButtonType.add, hoverText: 'Add a new tag group', onClick: (_) => controller.command(controller.UIAction.addTagGroup));
    addGroupButton.parent = _tagsContainer;
  }

  void addTagCategory(String id, TagGroupView tagGroupView) {
    _tagsContainer.insertBefore(tagGroupView.renderElement, addGroupButton.renderElement);
    groups[id] = tagGroupView;
  }

  void removeTagGroup(String id) {
    groups[id].renderElement.remove();
    groups.remove(id);
  }

  void clear() {
    int repliesNo = _tagsContainer.children.length;
    for (int i = 0; i < repliesNo; i++) {
      _tagsContainer.firstChild.remove();
    }
    assert(_tagsContainer.children.length == 0);
    groups.clear();
  }
}

class TagGroupView {
  DivElement _tagsGroupElement;
  DivElement _tagsContainer;
  SpanElement _title;
  Button _addTagButton;

  Map<String, TagView> tagViewsById;

  TagGroupView(String groupName) {
    _tagsGroupElement = new DivElement()..classes.add('tags-group');
    var removeGroupButton = new Button(ButtonType.remove, hoverText: 'Remove tags group', onClick: (_) {
      var removeWarningModal;
      removeWarningModal = new InlineOverlayModal('Are you sure you want to remove this group?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeTagGroup, new controller.TagGroupData(groupName))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => removeWarningModal.remove()),
      ]);
      removeWarningModal.parent = _tagsGroupElement;
    });
    removeGroupButton.parent = _tagsGroupElement;

    _title = new SpanElement()
      ..classes.add('tags-group__title')
      ..classes.add('foldable')
      ..text = groupName
      ..contentEditable = 'true'
      ..onBlur.listen((_) => controller.command(controller.UIAction.updateTagGroup, new controller.TagGroupData(groupName, newGroupName: _title.text)));
    _tagsGroupElement.append(_title);

    _tagsContainer = new DivElement()..classes.add('tags-group__tags');
    _tagsGroupElement.append(_tagsContainer);

    _addTagButton = new Button(ButtonType.add,
        hoverText: 'Add new tag', onClick: (_) => controller.command(controller.UIAction.addTag, new controller.TagData(null, groupId: groupName)));
    _addTagButton.parent = _tagsContainer;

    var separator = new DivElement()..classes.add('tags-group__separator');
    _tagsGroupElement.append(separator);

    _title.onClick.listen((event) {
      _tagsContainer.classes.toggle('hidden');
      _title.classes.toggle('folded');
    });
    // Start off folded
    _tagsContainer.classes.toggle('hidden', true);
    _title.classes.toggle('folded', true);

    tagViewsById = {};
  }

  Element get renderElement => _tagsGroupElement;

  void set name(String name) => _title.text = name;

  // void addTag(String id, TagView tagView) {
  //   _tagsContainer.append(tagView.renderElement);
  //   tags[id] = tagView;
  // }

  // void removeTag(String id) {
  //   tags[id].renderElement.remove();
  //   tags.remove(id);
  // }

  // void modifyTag(String id, TagView tagView) {
  //   _tagsContainer.insertBefore(tagView.renderElement, tags[id].renderElement);
  //   tags[id].renderElement.remove();
  //   tags[id] = tagView;
  // }

  void addTags(Map<String, TagView> tags) {
    for (var tag in tags.keys) {
      _tagsContainer.insertBefore(tags[tag].renderElement, _addTagButton.renderElement);
      tagViewsById[tag] = tags[tag];
    }

    _tagsContainer.style.display = 'block'; // briefly override any display settings to make sure we can compute getBoundingClientRect()
    List<num> widths = _tagsContainer.querySelectorAll('.tag__name').toList().map((e) => e.getBoundingClientRect().width).toList();
    _tagsContainer.style.display = ''; // clear inline display settings
    num avgGridWidth = widths.fold(0, (previousValue, width) => previousValue + width);
    avgGridWidth = avgGridWidth / widths.length;
    num colSpacing = 10;
    num minColWidth = math.min(avgGridWidth + 2 * colSpacing, 138);
    num containerWidth = _tagsContainer.getBoundingClientRect().width;
    num columnWidth = containerWidth / (containerWidth / minColWidth).floor() - colSpacing;
    _tagsContainer.style.setProperty('grid-template-columns', 'repeat(auto-fill, ${columnWidth}px)');
  }

  void modifyTags(Map<String, TagView> tags) {
    for (var tag in tags.keys) {
      _tagsContainer.insertBefore(tags[tag].renderElement, tagViewsById[tag].renderElement);
      tagViewsById[tag].renderElement.remove();
      tagViewsById[tag] = tags[tag];
    }
  }

  void removeTags(List<String> ids) {
    for (var id in ids) {
      tagViewsById[id].renderElement.remove();
      tagViewsById.remove(id);
    }
  }
}

enum TagStyle {
  None,
  Green,
  Yellow,
  Red,
  Important,
}

class TagView {
  DivElement tag;
  var _tagText;
  SpanElement _removeButton;
  String tagId;

  TagView(String text, String tagId, TagStyle tagStyle) {
    this.tagId = tagId;
    tag = new DivElement()
      ..classes.add('tag')
      ..dataset['id'] = tagId;
    switch (tagStyle) {
      case TagStyle.Green:
        tag.classes.add('tag--green');
        break;
      case TagStyle.Yellow:
        tag.classes.add('tag--yellow');
        break;
      case TagStyle.Red:
        tag.classes.add('tag--red');
        break;
      case TagStyle.Important:
        tag.classes.add('tag--important');
        break;
      default:
    }

    _tagText = new SpanElement()
      ..classes.add('tag__name')
      ..text = text
      ..title = text;
    _makeEditable(_tagText, onEnter: (e) => e.preventDefault());
    tag.append(_tagText);


    tag.onMouseDown.listen((event) {
      getSampleMessages(platform.fireStoreInstance, this.tagId).then((value) => print(value));
    });

    _removeButton = new SpanElement()..classes.add('tag__remove');
    tag.append(_removeButton);
    _removeButton.onClick.listen((e) {
      // controller.command(UIAction.cancelAddNewTagInline, new MessageTagData(tagId, int.parse(message.dataset['message-index'])));
    });
  }

  void focus() => _tagText.focus();

  Element get renderElement => tag;
}

void _makeEditable(Element element, {void onChange(e), void onEnter(e)}) {
  element
    ..contentEditable = 'true'
    ..onBlur.listen((e) {
      e.stopPropagation();
      if (onChange != null) onChange(e);
    })
    ..onKeyPress.listen((e) => e.stopPropagation())
    ..onKeyUp.listen((e) => e.stopPropagation())
    ..onKeyDown.listen((e) {
      e.stopPropagation();
      if (onEnter != null && e.keyCode == KeyCode.ENTER) {
        e.stopImmediatePropagation();
        onEnter(e);
      }
    });
}
