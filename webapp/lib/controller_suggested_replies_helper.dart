part of controller;


class SuggestedRepliesManager {
  static final SuggestedRepliesManager _singleton = SuggestedRepliesManager._internal();

  SuggestedRepliesManager._internal();

  factory SuggestedRepliesManager() => _singleton;

  int _lastSuggestedReplySeqNo = 0;
  int _lastSuggestedReplyGroupSeqNo = 0;

  int get lastSuggestedReplySeqNo => _lastSuggestedReplySeqNo;
  int get nextSuggestedReplySeqNo => ++_lastSuggestedReplySeqNo;

  int get lastSuggestedReplyGroupSeqNo => _lastSuggestedReplyGroupSeqNo;
  int get nextSuggestedReplyGroupSeqNo => ++_lastSuggestedReplyGroupSeqNo;

  String get nextSuggestedReplyId {
    var seqNo = nextSuggestedReplySeqNo;
    String paddedSeqNo = seqNo.toString().padLeft(6, '0');
    return 'reply-${paddedSeqNo}';
  }

  String get nextSuggestedReplyGroupId {
    var seqNo = nextSuggestedReplyGroupSeqNo;
    String paddedSeqNo = seqNo.toString().padLeft(6, '0');
    return 'reply-group-${paddedSeqNo}';
  }

  void _updateLastSuggestedReplySeqNo(int seqNo) {
    if (seqNo < _lastSuggestedReplySeqNo) return;
    _lastSuggestedReplySeqNo = seqNo;
  }

  void _updateLastSuggestedReplyGroupSeqNo(String groupId) {
    var seqNo = int.parse(groupId.split('reply-group-').last);
    if (seqNo < _lastSuggestedReplyGroupSeqNo) return;
    _lastSuggestedReplyGroupSeqNo = seqNo;
  }


  List<new_model.SuggestedReply> _suggestedReplies = [];
  List<new_model.SuggestedReply> get suggestedReplies => _suggestedReplies;

  Map<String, List<new_model.SuggestedReply>> _suggestedRepliesByCategory = {};
  Map<String, List<new_model.SuggestedReply>> get suggestedRepliesByCategory => _suggestedRepliesByCategory;

  Map<String, String> emptyGroups = {};

  Map<String, String> get groups => Map.fromEntries(_suggestedReplies.map((e) => MapEntry(e.groupId, e.groupDescription)));

  List<String> get categories => _suggestedRepliesByCategory.keys.toList()..sort();

  int getNextIndexInGroup(String groupId) {
    var suggestedRepliesInGroup = _suggestedReplies.where((r) => r.groupId == groupId);
    var lastIndexInGroup = suggestedRepliesInGroup.fold(0, (previousValue, r) => previousValue > r.indexInGroup ? previousValue : r.indexInGroup);
    return lastIndexInGroup + 1;
  }

  new_model.SuggestedReply getSuggestedReplyById(String id) => _suggestedReplies.singleWhere((r) => r.suggestedReplyId == id);


  void addSuggestedReply(new_model.SuggestedReply suggestedReply) => addSuggestedReplies([suggestedReply]);

  void addSuggestedReplies(List<new_model.SuggestedReply> suggestedReplies) {
    for (var suggestedReply in suggestedReplies) {
      _suggestedReplies.add(suggestedReply);
      _suggestedRepliesByCategory.putIfAbsent(suggestedReply.category, () => []);
      _suggestedRepliesByCategory[suggestedReply.category].add(suggestedReply);
      _updateLastSuggestedReplySeqNo(suggestedReply.seqNumber);
      _updateLastSuggestedReplyGroupSeqNo(suggestedReply.groupId);
      var groupDescription = emptyGroups.remove(suggestedReply.groupId);
      updateSuggestedRepliesGroupDescription(suggestedReply.groupId, groupDescription ?? suggestedReply.groupDescription);
    }
  }

  void updateSuggestedReply(new_model.SuggestedReply suggestedReply) => updateSuggestedReplies([suggestedReply]);

  void updateSuggestedReplies(List<new_model.SuggestedReply> suggestedReplies) {
    for (var suggestedReply in suggestedReplies) {
      var oldSuggestedReply = _suggestedReplies.singleWhere((r) => r.suggestedReplyId == suggestedReply.suggestedReplyId);
      var index = _suggestedReplies.indexOf(oldSuggestedReply);
      _suggestedReplies.replaceRange(index, index + 1, [suggestedReply]);
      index = _suggestedRepliesByCategory[suggestedReply.category].indexOf(oldSuggestedReply);
      _suggestedRepliesByCategory[suggestedReply.category].replaceRange(index, index + 1, [suggestedReply]);
    }
  }

  void updateSuggestedRepliesGroupDescription(String id, String newDescription) {
    if (emptyGroups.containsKey(id)) {
      emptyGroups[id] = newDescription;
      return;
    }
    for (var suggestedReply in _suggestedReplies) {
      if (suggestedReply.groupId != id) continue;
      suggestedReply.groupDescription = newDescription;
    }
  }

  void removeSuggestedReply(new_model.SuggestedReply suggestedReply) => removeSuggestedReplies([suggestedReply]);

  void removeSuggestedReplies(List<new_model.SuggestedReply> suggestedReplies) {
    var suggestedRepliesIds = new Set()..addAll(suggestedReplies.map((r) => r.suggestedReplyId));
    _suggestedReplies.removeWhere((suggestedReply) => suggestedRepliesIds.contains(suggestedReply.suggestedReplyId));
    for (var category in _suggestedRepliesByCategory.keys) {
      _suggestedRepliesByCategory[category].removeWhere((suggestedReply) => suggestedRepliesIds.contains(suggestedReply.suggestedReplyId));
    }
    for (var suggestedReply in suggestedReplies) {
      if (!groups.containsKey(suggestedReply.groupId)) {
        emptyGroups[suggestedReply.groupId] = suggestedReply.groupDescription;
      }
    }
    // Empty sublist if there are no replies to show
    if (_suggestedRepliesByCategory.isEmpty) {
      _suggestedRepliesByCategory[''] = [];
    }
  }

  void removeSuggestedRepliesGroup(String groupId) {
    List<new_model.SuggestedReply> suggestedRepliesToRemove = _suggestedReplies.where((r) => r.groupId == groupId).toList();
    removeSuggestedReplies(suggestedRepliesToRemove);
  }

}
