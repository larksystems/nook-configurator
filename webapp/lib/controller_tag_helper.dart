part of controller;


class TagManager {
  static final TagManager _singleton = TagManager._internal();

  TagManager._internal();

  factory TagManager() => _singleton;

  void addTag(new_model.Tag tag) => addTags([tag]);

  void addTags(List<new_model.Tag> tags) {
    // TODO
  }

  void updateTag(new_model.Tag tag) => updateTags([tag]);
  void updateTags(List<new_model.Tag> tags) {
    // TODO
  }

  void removeTag(new_model.Tag tag) => updateTags([tag]);
  void removeTags(List<new_model.Tag> tags) {
    // TODO
  }

}
