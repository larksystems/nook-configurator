library controller;

import 'dart:html';
import 'dart:math';

import 'package:uuid/uuid.dart' as uuid;
import 'package:nook/model.dart' as model;

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;
import 'router.dart';

part 'controller_view_helper.dart';
part 'controller_suggested_replies_helper.dart';
part 'controller_tag_helper.dart';

Logger log = new Logger('controller.dart');
Router router;

enum UIAction {
  userSignedIn,
  userSignedOut,
  signInButtonClicked,
  signOutButtonClicked,
  saveConfiguration,

  // Handling suggested replies
  addSuggestedReply,
  addSuggestedReplyGroup,
  updateSuggestedReply,
  updateSuggestedReplyGroup,
  removeSuggestedReply,
  removeSuggestedReplyGroup,
  changeSuggestedRepliesCategory,

  // Handling tags
  addTag,
  addTagGroup,
  renameTag,
  moveTag,
  updateTagGroup,
  removeTag,
  removeTagGroup
}

// ViewModel style data

class Data {}

class UserData extends Data {
  String displayName;
  String email;
  String photoUrl;
  UserData(this.displayName, this.email, this.photoUrl);

  @override
  String toString() {
    return "UserData($displayName, $email, $photoUrl)";
  }
}

class TagData extends Data {
  String id;

  /// Used when renaming a tag
  String text;

  /// Used when removing, or moving a tag
  String groupId;

  /// Used when moving a tag
  String newGroupId;
  TagData(this.id, {this.text, this.groupId, this.newGroupId});
}

class TagGroupData extends Data {
  String groupName;
  String newGroupName;
  TagGroupData(this.groupName, {this.newGroupName});
}

class SuggestedReplyData extends Data {
  String id;
  String text;
  String translation;
  String groupId;
  SuggestedReplyData(this.id, {this.text, this.translation, this.groupId});

  @override
  String toString() {
    return "SuggestedReplyData($id, '$text', '$translation', $groupId)";
  }
}

class SuggestedReplyGroupData extends Data {
  String groupId;
  String groupName;
  String newGroupName;
  SuggestedReplyGroupData(this.groupId, {this.groupName, this.newGroupName});

  @override
  String toString() {
    return "SuggestedReplyGroupData($groupName, $newGroupName)";
  }
}

class SuggestedRepliesCategoryData extends Data {
  String category;
  SuggestedRepliesCategoryData(this.category);

  @override
  String toString() {
    return "SuggestedRepliesCategoryData($category)";
  }
}

// ====

SuggestedRepliesManager suggestedRepliesManager = new SuggestedRepliesManager();
String selectedSuggestedRepliesCategory;
Set<String> editedSuggestedReplyIds = {};

TagManager tagManager = new TagManager();
Set<String> editedTagIds = {};

model.User signedInUser;

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void setupRoutes() {
  router = new Router()
    ..addAuthHandler(new Route('#/auth', loadAuthView))
    ..addDefaultHandler(new Route('#/configuration', loadConfigurationSelectionView))
    ..addHandler(new Route('#/configuration/tags', loadTagsConfigurationView))
    ..addHandler(new Route('#/configuration/suggested-replies', loadSuggestedRepliesConfigurationView))
    ..listen();
}

var page;

void command(UIAction action, [Data actionData]) {
  log.verbose('command => $action : $actionData');
  switch (action) {
    case UIAction.userSignedIn:
      UserData userData = actionData;
      signedInUser = new model.User()
        ..userName = userData.displayName
        ..userEmail = userData.email;
      view.navView.authHeaderViewPartial.signIn(userData.displayName, userData.photoUrl);
      router.routeTo(window.location.hash);
      break;
    case UIAction.userSignedOut:
      signedInUser = null;
      view.navView.authHeaderViewPartial.signOut();
      view.navView.projectTitle = '';
      router.routeTo('#/auth');
      break;
    case UIAction.signInButtonClicked:
      platform.signIn();
      break;
    case UIAction.signOutButtonClicked:
      platform.signOut();
      break;
    case UIAction.saveConfiguration:
      switch (page) {
        case 'tags':
          saveTagsConfiguration();
          break;
        case 'replies':
          saveSuggestedRepliesConfiguration();
          break;
      }
      break;

    case UIAction.addSuggestedReply:
      SuggestedReplyData data = actionData;
      var newSuggestedReply = model.SuggestedReply()
        ..docId = suggestedRepliesManager.nextSuggestedReplyId
        ..text = ''
        ..translation = ''
        ..shortcut = ''
        ..seqNumber = suggestedRepliesManager.lastSuggestedReplySeqNo
        ..category = selectedSuggestedRepliesCategory
        ..groupId = data.groupId
        ..groupDescription = suggestedRepliesManager.groups[data.groupId]
        ..indexInGroup = suggestedRepliesManager.getNextIndexInGroup(data.groupId);
      suggestedRepliesManager.addSuggestedReply(newSuggestedReply);

      var newSuggestedReplyView = new view.SuggestedReplyView(newSuggestedReply.docId, newSuggestedReply.text, newSuggestedReply.translation);
      (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage)
          .groups[data.groupId]
          .addReply(newSuggestedReply.suggestedReplyId, newSuggestedReplyView);
      editedSuggestedReplyIds.add(newSuggestedReply.docId);
      break;
    case UIAction.updateSuggestedReply:
      SuggestedReplyData data = actionData;
      var suggestedReply = suggestedRepliesManager.getSuggestedReplyById(data.id);
      if (data.text != null) {
        suggestedReply.text = data.text;
      }
      if (data.translation != null) {
        suggestedReply.translation = data.translation;
      }
      editedSuggestedReplyIds.add(data.id);
      break;
    case UIAction.removeSuggestedReply:
      SuggestedReplyData data = actionData;
      var suggestedReply = suggestedRepliesManager.getSuggestedReplyById(data.id);
      suggestedRepliesManager.removeSuggestedReply(suggestedReply);
      (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).groups[suggestedReply.groupId].removeReply(suggestedReply.suggestedReplyId);
      // TODO: queue suggested replies for removal once the backend infrastructure can handle removing them
      break;
    case UIAction.addSuggestedReplyGroup:
      var newGroupId = suggestedRepliesManager.nextSuggestedReplyGroupId;
      suggestedRepliesManager.emptyGroups[newGroupId] = '';
      var suggestedReplyGroupView = new view.SuggestedReplyGroupView(newGroupId, suggestedRepliesManager.emptyGroups[newGroupId]);
      // TODO: This will only work when the view is active, async updates will cause a
      (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).addReplyGroup(newGroupId, suggestedReplyGroupView);
      break;
    case UIAction.updateSuggestedReplyGroup:
      SuggestedReplyGroupData data = actionData;
      suggestedRepliesManager.updateSuggestedRepliesGroupDescription(data.groupId, data.newGroupName);
      (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).groups[data.groupId].name = data.newGroupName;
      break;
    case UIAction.removeSuggestedReplyGroup:
      SuggestedReplyGroupData data = actionData;
      suggestedRepliesManager.removeSuggestedRepliesGroup(data.groupId);
      (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).removeReplyGroup(data.groupId);
      break;
    case UIAction.changeSuggestedRepliesCategory:
      SuggestedRepliesCategoryData data = actionData;
      selectedSuggestedRepliesCategory = data.category;
      _populateSuggestedRepliesConfigPage(suggestedRepliesManager.suggestedRepliesByCategory[selectedSuggestedRepliesCategory]);
      break;

    case UIAction.addTag:
      TagData data = actionData;
      var newTag = new model.Tag()
        ..docId = generateTagId()
        ..filterable = true
        ..groups = [data.groupId]
        ..isUnifier = false
        ..text = ''
        ..shortcut = ''
        ..visible = true
        ..type = model.TagType.Normal;

      tagManager.addTag(newTag);

      _addTagsToView({
        data.groupId: [newTag]
      });
      editedTagIds.add(newTag.docId);
      break;

    case UIAction.renameTag:
      TagData data = actionData;
      model.Tag tag = tagManager.getTagById(data.id);
      tag.text = data.text;
      print(data.text);
      editedTagIds.add(data.id);
      _modifyTagsInView(Map.fromEntries(tag.groups.map((g) => new MapEntry(g, [tag]))));
      break;
    case UIAction.moveTag:
      TagData data = actionData;
      model.Tag tag = tagManager.getTagById(data.id);
      tag.groups.remove(data.groupId);
      tag.groups.add(data.newGroupId);
      editedTagIds.add(data.id);
      _removeTagsFromView({
        data.groupId: [tag]
      });
      _addTagsToView({
        data.newGroupId: [tag]
      });
      break;
    case UIAction.removeTag:
      TagData data = actionData;
      model.Tag tag = tagManager.getTagById(data.id);
      tag.groups.remove(data.groupId);
      _removeTagsFromView({
        data.groupId: [tag]
      });
      if (tag.groups.isEmpty) {
        // handle removals
      } else {
        editedTagIds.add(data.id);
      }
      break;
    case UIAction.addTagGroup:
      var newGroupName = tagManager.nextTagGroupName;
      tagManager.namesOfEmptyGroups.add(newGroupName);
      _addTagsToView({newGroupName: []});
      break;
    case UIAction.updateTagGroup:
      TagGroupData data = actionData;

      break;
    case UIAction.removeTagGroup:

      // throw "Not implemented";
      // TODO: Handle this case.
      break;
  }
}

void saveSuggestedRepliesConfiguration() {
  List<model.SuggestedReply> repliesToSave =
      editedSuggestedReplyIds.map((suggestedReplyId) => suggestedRepliesManager.getSuggestedReplyById(suggestedReplyId)).toList();
  (view.contentView.renderedPage as view.ConfigurationPage).showSaveStatus('Saving...');
  saveSuggestedReplies(repliesToSave).then((value) {
    (view.contentView.renderedPage as view.ConfigurationPage).showSaveStatus('Saved!');
  }, onError: (error, stacktrace) {
    (view.contentView.renderedPage as view.ConfigurationPage)
        .showSaveStatus('Unable to save. Please check your connection and try again. If the issue persists, please contact your project administrator');
  });
}

void saveTagsConfiguration() {
  List<model.Tag> tagsToSave = editedTagIds.map((tagId) => tagManager.getTagById(tagId)).toList();
  (view.contentView.renderedPage as view.ConfigurationPage).showSaveStatus('Saving...');
  saveTags(tagsToSave).then((value) {
    (view.contentView.renderedPage as view.ConfigurationPage).showSaveStatus('Saved!');
  }, onError: (error, stacktrace) {
    (view.contentView.renderedPage as view.ConfigurationPage)
        .showSaveStatus('Unable to save. Please check your connection and try again. If the issue persists, please contact your project administrator');
  });
}

void loadAuthView() {
  view.contentView.renderView(new view.AuthPage());
}

void loadConfigurationSelectionView() {
  var configSelectionPage = new view.ConfigurationSelectionPage();
  view.contentView.renderView(configSelectionPage);
}

void loadSuggestedRepliesConfigurationView() {
  page = 'replies';
  view.contentView.renderView(new view.SuggestedRepliesConfigurationPage());

  platform.listenForSuggestedReplies((added, modified, removed) {
    suggestedRepliesManager.addSuggestedReplies(added);
    suggestedRepliesManager.updateSuggestedReplies(modified);
    suggestedRepliesManager.removeSuggestedReplies(removed);

    // Replace list of categories in the UI selector
    (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).categories = suggestedRepliesManager.categories;
    // If the categories have changed under us and the selected one no longer exists,
    // default to the first category, whichever it is
    if (!suggestedRepliesManager.categories.contains(selectedSuggestedRepliesCategory)) {
      selectedSuggestedRepliesCategory = suggestedRepliesManager.categories.first;
    }
    // Select the selected category in the UI and add the suggested replies for it
    (view.contentView.renderedPage as view.SuggestedRepliesConfigurationPage).selectedCategory = selectedSuggestedRepliesCategory;
    _populateSuggestedRepliesConfigPage(suggestedRepliesManager.suggestedRepliesByCategory[selectedSuggestedRepliesCategory]);
  });
}

void loadTagsConfigurationView() {
  page = 'tags';
  view.contentView.renderView(new view.TagsConfigurationPage());

  platform.listenForTags((added, modified, removed) {
    tagManager.addTags(added);
    tagManager.updateTags(modified);
    tagManager.removeTags(removed);

    _addTagsToView(_groupTagsIntoCategories(added));
    _modifyTagsInView(_groupTagsIntoCategories(modified));
    _removeTagsFromView(_groupTagsIntoCategories(removed));
  });
}

Future<void> saveSuggestedReplies(List<model.SuggestedReply> suggestedReplies) {
  return platform.updateSuggestedReplies(suggestedReplies);
}

Future<void> saveTags(List<model.Tag> tags) {
  return platform.updateTags(tags);
}
