part of controller;


void _populateReplyPanelView(List<new_model.SuggestedReply> replies) {
  Map<String, List<new_model.SuggestedReply>> repliesByGroups = _groupRepliesIntoGroups(replies);
  (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.clear();
  for (var groupId in repliesByGroups.keys) {
    var repliesInGroup = repliesByGroups[groupId];
    if (repliesInGroup.isEmpty) continue;
    var groupDescription = repliesInGroup.first.groupDescription;
    view.SuggestedReplyGroupView group = new view.SuggestedReplyGroupView(groupDescription);
    for (var reply in repliesInGroup) {
      var replyView = new view.SuggestedReplyView(reply.docId, reply.text, reply.translation);
      group.addReply(replyView);
    }
    (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.addReplyGroup(group);
  }
}

Map<String, List<new_model.SuggestedReply>> _groupRepliesIntoCategories(List<new_model.SuggestedReply> replies) {
  Map<String, List<new_model.SuggestedReply>> result = {};
  for (new_model.SuggestedReply reply in replies) {
    String category = reply.category ?? '';
    if (!result.containsKey(category)) {
      result[category] = [];
    }
    result[category].add(reply);
  }
  return result;
}

Map<String, List<new_model.SuggestedReply>> _groupRepliesIntoGroups(List<new_model.SuggestedReply> replies) {
  Map<String, List<new_model.SuggestedReply>> result = {};
  for (new_model.SuggestedReply reply in replies) {
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
