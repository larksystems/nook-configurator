part of controller;


class TagManager {
  static final TagManager _singleton = TagManager._internal();

  List<new_model.Tag> _tags = <new_model.Tag>[];
  List<new_model.Tag> get tags => _tags;

  TagManager._internal();

  factory TagManager() => _singleton;

  void addTag(new_model.Tag tag) => addTags([tag]);

  void addTags(List<new_model.Tag> tags) {
    for (var tag in tags) {
      if (_tags.any((t) => t.tagId == tag.tagId)) {
        throw "Tag consistency error: Adding tag that already exist, ${tag.tagId}";
      }
      _tags.add(tag);
    }
  }

  void updateTag(new_model.Tag tag) => updateTags([tag]);
  void updateTags(List<new_model.Tag> tags) {
    for (var tag in tags) {
      if (!_tags.any((t) => t.tagId == tag.tagId)) {
        throw "Tag consistency error: Updating tag that doesn't exist, ${tag.tagId}";
      }

      _tags.removeWhere((t) => t.tagId == tag.tagId);
      _tags.add(tag);
    }

  }

  void removeTag(new_model.Tag tag) => updateTags([tag]);
  void removeTags(List<new_model.Tag> tags) {
    for (var tag in tags) {
      if (!_tags.any((t) => t.tagId == tag.tagId)) {
        throw "Tag consistency error: Updating tag that doesn't exist, ${tag.tagId}";
      }

      _tags.removeWhere((t) => t.tagId == tag.tagId);
    }
  }
}
