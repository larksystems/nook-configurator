part of controller;

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
