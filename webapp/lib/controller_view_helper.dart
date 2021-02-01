part of controller;

void _populateSuggestedRepliesConfigPage(List<model.SuggestedReply> replies) {
  Map<String, List<model.SuggestedReply>> repliesByGroups = _groupRepliesIntoGroups(replies);
  (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).clear();
  for (var groupId in repliesByGroups.keys) {
    var repliesInGroup = repliesByGroups[groupId];
    if (repliesInGroup.isEmpty) continue;
    var groupDescription = repliesInGroup.first.groupDescription;
    view.SuggestedReplyGroupView group = new view.SuggestedReplyGroupView(groupId, groupDescription);
    for (var reply in repliesInGroup) {
      var replyView = new view.SuggestedReplyView(reply.docId, reply.text, reply.translation);
      group.addReply(reply.docId, replyView);
    }
    (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).addReplyGroup(groupId, group);
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

Map<String, List<model.SuggestedReply>> _groupRepliesIntoGroups(List<model.SuggestedReply> replies) {
  Map<String, List<model.SuggestedReply>> result = {};
  for (model.SuggestedReply reply in replies) {
    if (!result.containsKey(reply.groupId)) {
      result[reply.groupId] = [];
    }
    result[reply.groupId].add(reply);
  }
  for (String groupId in result.keys) {
    // TODO (mariana): once we've transitioned to using groups, we can remove the sequence number comparison
    result[groupId].sort((reply1, reply2) => (reply1.indexInGroup ?? reply1.seqNumber).compareTo(reply2.indexInGroup ?? reply2.seqNumber));
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
