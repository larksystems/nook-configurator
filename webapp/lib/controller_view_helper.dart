part of controller;


void _populateReplyPanelView(List<new_model.SuggestedReply> replies) {
  Map<String, List<new_model.SuggestedReply>> repliesByGroups = _groupRepliesIntoGroups(replies);
  (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.clear();
  for (var groupId in repliesByGroups.keys) {
    var repliesInGroup = repliesByGroups[groupId];
    if (repliesInGroup.isEmpty) continue;
    var groupDescription = repliesInGroup.first.groupDescription;
    view.SuggestedReplyGroupView group = new view.SuggestedReplyGroupView(groupId, groupDescription);
    for (var reply in repliesInGroup) {
      var replyView = new view.SuggestedReplyView(reply.docId, reply.text, reply.translation);
      group.addReply(reply.docId, replyView);
    }
    (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.addReplyGroup(groupId, group);
  }
}

void _populateTagsView(List<new_model.Tag> tags) {
  // TODO




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
