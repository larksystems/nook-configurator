part of controller;

void _populateStandardMessagesConfigPage(List<model.SuggestedReply> messages) {
  Map<String, List<model.SuggestedReply>> messagesByGroups = _groupMessagesIntoGroups(messages);
  (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).clear();
  for (var groupId in messagesByGroups.keys) {
    var messagesInGroup = messagesByGroups[groupId];
    if (messagesInGroup.isEmpty) continue;
    var groupDescription = messagesInGroup.first.groupDescription;
    view.StandardMessagesGroupView group = new view.StandardMessagesGroupView(groupId, groupDescription);
    for (var message in messagesInGroup) {
      var messageView = new view.StandardMessageView(message.docId, message.text, message.translation);
      group.addMessage(message.docId, messageView);
    }
    (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).addGroup(groupId, group);
  }
}

void _addTagsToView(Map<String, List<model.Tag>> tagsByCategory) {
  view.TagsConfigurationPage configPage = view.contentView.renderedPage;
  for (var category in tagsByCategory.keys.toList()..sort()) {
    if (!configPage.groups.containsKey(category)) {
      configPage.addTagCategory(category, new view.TagGroupView(category));
    }
    Map<String, view.TagView> tagsById = {};
    for (var tag in tagsByCategory[category]) {
      tagsById[tag.tagId] = new view.TagView(tag.text, tag.docId, category, _tagTypeToStyle(tag.type));
    }
    configPage.groups[category].addTags(tagsById);
  }
}

void _removeTagsFromView(Map<String, List<model.Tag>> tagsByCategory) {
  view.TagsConfigurationPage configPage = view.contentView.renderedPage;
  for (var category in tagsByCategory.keys.toList()..sort()) {
    configPage.groups[category].removeTags(tagsByCategory[category].map((t) => t.tagId).toList());
  }
}

void _modifyTagsInView(Map<String, List<model.Tag>> tagsByCategory) {
  view.TagsConfigurationPage configPage = view.contentView.renderedPage;
  for (var category in tagsByCategory.keys.toList()..sort()) {
    Map<String, view.TagView> tagViewsById = {};
    for (var tag in tagsByCategory[category]) {
      tagViewsById[tag.tagId] = new view.TagView(tag.text, tag.docId, category, _tagTypeToStyle(tag.type));
    }
    configPage.groups[category].modifyTags(tagViewsById);
  }
}

Map<String, List<model.SuggestedReply>> _groupMessagesIntoGroups(List<model.SuggestedReply> messages) {
  Map<String, List<model.SuggestedReply>> result = {};
  for (model.SuggestedReply message in messages) {
    if (!result.containsKey(message.groupId)) {
      result[message.groupId] = [];
    }
    result[message.groupId].add(message);
  }
  for (String groupId in result.keys) {
    // TODO (mariana): once we've transitioned to using groups, we can remove the sequence number comparison
    result[groupId].sort((message1, message2) => (message1.indexInGroup ?? message1.seqNumber).compareTo(message2.indexInGroup ?? message2.seqNumber));
  }
  return result;
}

Map<String, List<model.Tag>> _groupTagsIntoCategories(List<model.Tag> tags) {
  Map<String, List<model.Tag>> result = {};
  for (model.Tag tag in tags) {
    if (tag.groups.isEmpty) {
      if (tag.group.isEmpty) {
        result.putIfAbsent("", () => []).add(tag);
        continue;
      }
      result.putIfAbsent(tag.group, () => []).add(tag);
      continue;
    }
    for (var group in tag.groups) {
      result.putIfAbsent(group, () => []).add(tag);
    }
  }
  // Sort tags alphabetically
  for (var tags in result.values) {
    tags.sort((t1, t2) => t1.text.compareTo(t2.text));
  }
  return result;
}

view.TagStyle _tagTypeToStyle(model.TagType tagType) {
  switch (tagType) {
    case model.TagType.Important:
      return view.TagStyle.Important;
    default:
      if (tagType == model.NotFoundTagType.NotFound) {
        return view.TagStyle.Yellow;
      }
      return view.TagStyle.None;
  }
}
