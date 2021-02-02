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
    int messagesNo = _tagsContainer.children.length;
    for (int i = 0; i < messagesNo; i++) {
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
  EditableText _editableTitle;
  Button _addTagButton;

  Map<String, TagView> tagViewsById;

  TagGroupView(String groupName) {
    _tagsGroupElement = new DivElement()..classes.add('tags-group');
    var tagsDropzone = new dnd.Dropzone(_tagsGroupElement);
    tagsDropzone.onDrop.listen((event) {
      var tag = event.draggableElement;
      var tagId = tag.dataset['id'];
      var groupId = tag.dataset['group-id'];
      controller.command(controller.UIAction.moveTag, new controller.TagData(tagId, groupId: groupId, newGroupId: groupName));
      tag.remove();
    });

    var removeGroupButton = new Button(ButtonType.remove, hoverText: 'Remove tags group', onClick: (_) {
      _title.classes.toggle('folded', false); // show the tag group before deletion
      var warningModal;
      warningModal = new InlineOverlayModal('Are you sure you want to remove this group?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeTagGroup, new controller.TagGroupData(groupName))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => warningModal.remove()),
      ]);
      warningModal.parent = _tagsGroupElement;
    });
    removeGroupButton.parent = _tagsGroupElement;

    _title = new SpanElement()
      ..classes.add('tags-group__title')
      ..classes.add('foldable')
      ..text = groupName;
    _editableTitle = new EditableText(_title,
        onEditStart: (_) => _title.classes.remove('foldable'),
        onEditEnd: (_) => _title.classes.add('foldable'),
        onSave: (_) => controller.command(controller.UIAction.updateTagGroup, new controller.TagGroupData(groupName, newGroupName: _title.text)));
    _editableTitle.parent = _tagsGroupElement;

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

  void addTags(Map<String, TagView> tags) {
    for (var tag in tags.keys) {
      _tagsContainer.insertBefore(tags[tag].renderElement, _addTagButton.renderElement);
      tagViewsById[tag] = tags[tag];
    }

    _tagsContainer.style.display = 'block'; // briefly override any display settings to make sure we can compute getBoundingClientRect()
    bool hidden = _tagsContainer.classes.contains('hidden');
    _tagsContainer.classes.toggle('hidden', false); // briefly override any display settings to make sure we can compute getBoundingClientRect()
    List<num> widths = _tagsContainer.querySelectorAll('.tag__name').toList().map((e) => e.getBoundingClientRect().width).toList();
    num containerWidth = _tagsContainer.getBoundingClientRect().width;
    _tagsContainer.style.display = ''; // clear inline display settings
    _tagsContainer.classes.toggle('hidden', hidden);

    num maxGridWidth = widths.fold(0, (previousValue, width) => width > previousValue ? width : previousValue);
    num colSpacing = 10;
    num minColWidth = maxGridWidth + 2 * colSpacing + 50;
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

// This enum was adapted from Nook
enum TagStyle {
  None,
  Green,
  Yellow,
  Red,
  Important,
}

// This class was adapted from Nook
class TagView {
  DivElement tag;
  SpanElement _tagText;
  EditableText _editableTag;
  String tagId;

  TagView(String text, String tagId, String groupId, TagStyle tagStyle) {
    this.tagId = tagId;
    tag = new DivElement()
      ..classes.add('tag')
      ..dataset['id'] = tagId
      ..dataset['group-id'] = groupId;
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
    var draggableTag = new dnd.Draggable(tag, avatarHandler: dnd.AvatarHandler.original(), draggingClass: 'tag__name');

    _tagText = new SpanElement()
      ..classes.add('tag__name')
      ..text = text
      ..title = text;

    _editableTag = new EditableText(_tagText,
        onEditStart: (_) => draggableTag.destroy(),
        onEditEnd: (_) => new dnd.Draggable(tag, avatarHandler: dnd.AvatarHandler.original(), draggingClass: 'tag__name'),
        onSave: (_) => controller.command(controller.UIAction.renameTag, new controller.TagData(tagId, text: _tagText.text)));
    _editableTag.parent = tag;

    var removeButton = new Button(ButtonType.remove, hoverText: 'Remove tag', onClick: (_) {
      var warningModal;
      warningModal = new PopupModal('Are you sure you want to remove this tag?', [
        new Button(ButtonType.text,
            buttonText: 'Yes', onClick: (_) => controller.command(controller.UIAction.removeTag, new controller.TagData(tagId, groupId: groupId))),
        new Button(ButtonType.text, buttonText: 'No', onClick: (_) => warningModal.remove()),
      ]);
      warningModal.parent = tag;
    });
    removeButton.parent = tag;

    var sampleMessagesButton = new Button(ButtonType.speech, hoverText: 'Get sample messages', onClick: (_) {
      var tooltip = new SampleMessagesTooltip('Sample messages for tag "$text"');
      tooltip.parent = tag;
      getSampleMessages(platform.fireStoreInstance, this.tagId).then((value) => tooltip.displayMessages(value));
    });
    sampleMessagesButton.parent = tag;
  }

  void focus() => _tagText.focus();

  Element get renderElement => tag;
}

class SampleMessagesTooltip {
  DivElement tooltip;
  DivElement _messages;

  SampleMessagesTooltip(String title) {
    tooltip = new DivElement()..classes.add('tooltip');

    tooltip.append(new ParagraphElement()
      ..classes.add('tooltip__title')
      ..text = title);

    var removeButton = new Button(ButtonType.remove, hoverText: 'Close sample messages tooltip', onClick: (_) => remove());
    removeButton.renderElement.style
      ..position = 'absolute'
      ..top = '0'
      ..right = '10px';
    removeButton.parent = tooltip;

    _messages = new DivElement()..classes.add('tooltip__messages');
    tooltip.append(_messages);
  }

  void displayMessages(List<String> messages) {
    for (var message in messages) {
      _messages.append(new DivElement()
        ..classes.add('tooltip__message')
        ..text = message);
    }
  }

  void set parent(Element value) => value.append(tooltip);
  void remove() => tooltip.remove();

  void set visible(bool value) {
    tooltip.classes.toggle('hidden', !value);
  }
}
