part of controller;


class TagManager {
  static final TagManager _singleton = TagManager._internal();

  List<model.Tag> _tags = <model.Tag>[];
  List<model.Tag> get tags => _tags;

  TagManager._internal();

  factory TagManager() => _singleton;

  void addTag(model.Tag tag) => addTags([tag]);

  void addTags(List<model.Tag> tags) {
    for (var tag in tags) {
      if (_tags.any((t) => t.tagId == tag.tagId)) {
        throw "Tag consistency error: Adding tag that already exist, ${tag.tagId}";
      }
      _tags.add(tag);
    }
  }

  void updateTag(model.Tag tag) => updateTags([tag]);
  void updateTags(List<model.Tag> tags) {
    for (var tag in tags) {
      if (!_tags.any((t) => t.tagId == tag.tagId)) {
        throw "Tag consistency error: Updating tag that doesn't exist, ${tag.tagId}";
      }

      _tags.removeWhere((t) => t.tagId == tag.tagId);
      _tags.add(tag);
    }

  }

  void removeTag(model.Tag tag) => updateTags([tag]);
  void removeTags(List<model.Tag> tags) {
    for (var tag in tags) {
      if (!_tags.any((t) => t.tagId == tag.tagId)) {
        throw "Tag consistency error: Updating tag that doesn't exist, ${tag.tagId}";
      }

      _tags.removeWhere((t) => t.tagId == tag.tagId);
    }
  }
}
