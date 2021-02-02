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
part 'controller_messages_helper.dart';
part 'controller_tag_helper.dart';

Logger log = new Logger('controller.dart');
Router router;

enum UIAction {
  userSignedIn,
  userSignedOut,
  signInButtonClicked,
  signOutButtonClicked,
  saveConfiguration,

  // Handling standard messages
  addStandardMessage,
  addStandardMessagesGroup,
  updateStandardMessage,
  updateStandardMessagesGroup,
  removeStandardMessage,
  removeStandardMessagesGroup,
  changeStandardMessagesCategory,

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

class StandardMessageData extends Data {
  String id;
  String text;
  String translation;
  String groupId;
  StandardMessageData(this.id, {this.text, this.translation, this.groupId});

  @override
  String toString() {
    return "StandardMessageData($id, '$text', '$translation', $groupId)";
  }
}

class StandardMessagesGroupData extends Data {
  String groupId;
  String groupName;
  String newGroupName;
  StandardMessagesGroupData(this.groupId, {this.groupName, this.newGroupName});

  @override
  String toString() {
    return "StandardMessagesGroupData($groupName, $newGroupName)";
  }
}

class StandardMessagesCategoryData extends Data {
  String category;
  StandardMessagesCategoryData(this.category);

  @override
  String toString() {
    return "StandardMessagesCategoryData($category)";
  }
}

// ====

StandardMessagesManager standardMessagesManager = new StandardMessagesManager();
String selectedStandardMessagesCategory;
Set<String> editedStandardMessageIds = {};

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
    ..addHandler(new Route('#/configuration/messages', loadStandardMessagesConfigurationView))
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
        case 'messages':
          saveStandardMessagesConfiguration();
          break;
      }
      break;

    case UIAction.addStandardMessage:
      StandardMessageData data = actionData;
      var newStandardMessage = model.SuggestedReply()
        ..docId = standardMessagesManager.nextStandardMessageId
        ..text = ''
        ..translation = ''
        ..shortcut = ''
        ..seqNumber = standardMessagesManager.lastStandardMessageSeqNo
        ..category = selectedStandardMessagesCategory
        ..groupId = data.groupId
        ..groupDescription = standardMessagesManager.groups[data.groupId]
        ..indexInGroup = standardMessagesManager.getNextIndexInGroup(data.groupId);
      standardMessagesManager.addStandardMessage(newStandardMessage);

      var newStandardMessageView = new view.StandardMessageView(newStandardMessage.docId, newStandardMessage.text, newStandardMessage.translation);
      (view.contentView.renderedPage as view.StandardMessagesConfigurationPage)
          .groups[data.groupId]
          .addMessage(newStandardMessage.suggestedReplyId, newStandardMessageView);
      editedStandardMessageIds.add(newStandardMessage.docId);
      break;
    case UIAction.updateStandardMessage:
      StandardMessageData data = actionData;
      var standardMessage = standardMessagesManager.getStandardMessageById(data.id);
      if (data.text != null) {
        standardMessage.text = data.text;
      }
      if (data.translation != null) {
        standardMessage.translation = data.translation;
      }
      editedStandardMessageIds.add(data.id);
      break;
    case UIAction.removeStandardMessage:
      StandardMessageData data = actionData;
      var standardMessage = standardMessagesManager.getStandardMessageById(data.id);
      standardMessagesManager.removeStandardMessage(standardMessage);
      (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).groups[standardMessage.groupId].removeMessage(standardMessage.suggestedReplyId);
      // TODO: queue suggested messages for removal once the backend infrastructure can handle removing them
      break;
    case UIAction.addStandardMessagesGroup:
      var newGroupId = standardMessagesManager.nextStandardMessagesGroupId;
      standardMessagesManager.emptyGroups[newGroupId] = '';
      var standardMessagesGroupView = new view.StandardMessagesGroupView(newGroupId, standardMessagesManager.emptyGroups[newGroupId]);
      // TODO: This will only work when the view is active, async updates will cause a
      (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).addGroup(newGroupId, standardMessagesGroupView);
      break;
    case UIAction.updateStandardMessagesGroup:
      StandardMessagesGroupData data = actionData;
      standardMessagesManager.updateStandardMessagesGroupDescription(data.groupId, data.newGroupName);
      (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).groups[data.groupId].name = data.newGroupName;
      break;
    case UIAction.removeStandardMessagesGroup:
      StandardMessagesGroupData data = actionData;
      standardMessagesManager.removeStandardMessagesGroup(data.groupId);
      (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).removeGroup(data.groupId);
      break;
    case UIAction.changeStandardMessagesCategory:
      StandardMessagesCategoryData data = actionData;
      selectedStandardMessagesCategory = data.category;
      _populateStandardMessagesConfigPage(standardMessagesManager.standardMessagesByCategory[selectedStandardMessagesCategory]);
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

void saveStandardMessagesConfiguration() {
  List<model.SuggestedReply> messagesToSave =
      editedStandardMessageIds.map((standardMessageId) => standardMessagesManager.getStandardMessageById(standardMessageId)).toList();
  (view.contentView.renderedPage as view.ConfigurationPage).showSaveStatus('Saving...');
  saveStandardMessages(messagesToSave).then((value) {
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

void loadStandardMessagesConfigurationView() {
  page = 'messages';
  view.contentView.renderView(new view.StandardMessagesConfigurationPage());

  platform.listenForSuggestedReplies((added, modified, removed) {
    standardMessagesManager.addStandardMessages(added);
    standardMessagesManager.updateStandardMessages(modified);
    standardMessagesManager.removeStandardMessages(removed);

    // Replace list of categories in the UI selector
    (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).categories = standardMessagesManager.categories;
    // If the categories have changed under us and the selected one no longer exists,
    // default to the first category, whichever it is
    if (!standardMessagesManager.categories.contains(selectedStandardMessagesCategory)) {
      selectedStandardMessagesCategory = standardMessagesManager.categories.first;
    }
    // Select the selected category in the UI and add the standard messages for it
    (view.contentView.renderedPage as view.StandardMessagesConfigurationPage).selectedCategory = selectedStandardMessagesCategory;
    _populateStandardMessagesConfigPage(standardMessagesManager.standardMessagesByCategory[selectedStandardMessagesCategory]);
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

Future<void> saveStandardMessages(List<model.SuggestedReply> standardMessages) {
  return platform.updateSuggestedReplies(standardMessages);
}

Future<void> saveTags(List<model.Tag> tags) {
  return platform.updateTags(tags);
}
