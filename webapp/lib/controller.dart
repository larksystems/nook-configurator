library controller;


import 'dart:html';

import 'package:nook/model.dart' as new_model;

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;
import 'router.dart';
import 'model.dart' as model;

part 'controller_view_helper.dart';
part 'controller_suggested_replies_helper.dart';

Logger log = new Logger('controller.dart');
Router router;

enum UIAction {
  userSignedIn,
  userSignedOut,
  signInButtonClicked,
  signOutButtonClicked,
  savePackageConfiguration,
  saveTagsConfiguration,

  // Handling suggested replies
  addSuggestedReply,
  addSuggestedReplyGroup,
  updateSuggestedReply,
  updateSuggestedReplyGroup,
  removeSuggestedReply,
  removeSuggestedReplyGroup,
  changeSuggestedRepliesCategory,
}

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



List<String> configurationSuggestedReplyLanguages;
SuggestedRepliesManager suggestedRepliesManager = new SuggestedRepliesManager();
String selectedSuggestedRepliesCategory;
List<String> editedSuggestedReplies = [];

model.User signedInUser;
final String selectedPackage = 'Change communications';

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  router.routeTo(window.location.hash);

  // Listener inits

  platform.listenForSuggestedReplies(
  (added, modified, removed) {
    suggestedRepliesManager.addSuggestedReplies(added);
    suggestedRepliesManager.updateSuggestedReplies(modified);
    suggestedRepliesManager.removeSuggestedReplies(removed);

    // Replace list of categories in the UI selector
    (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.categories = suggestedRepliesManager.categories;
    // If the categories have changed under us and the selected one no longer exists,
    // default to the first category, whichever it is
    if (!suggestedRepliesManager.categories.contains(selectedSuggestedRepliesCategory)) {
      selectedSuggestedRepliesCategory = suggestedRepliesManager.categories.first;
    }
    // Select the selected category in the UI and add the suggested replies for it
    (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.selectedCategory = selectedSuggestedRepliesCategory;
    _populateReplyPanelView(suggestedRepliesManager.suggestedRepliesByCategory[selectedSuggestedRepliesCategory]);
  });
}

void setupRoutes() {
  router = new Router()
    ..addAuthHandler(new Route('#/auth', loadAuthView))
    ..addDefaultHandler(new Route('#/configuration/tags', loadTagConfigurationView))
    ..addDefaultHandler(new Route('#/configuration', loadPackageConfigurationView))
    ..listen();
}

void command(UIAction action, [Data actionData]) {
  log.verbose('command => $action : $actionData');
  switch (action) {
    case UIAction.userSignedIn:
      UserData userData = actionData;
      signedInUser = new model.User()
        ..userName = userData.displayName
        ..userEmail = userData.email;
      view.navView.authHeaderViewPartial.signIn(userData.displayName, userData.photoUrl);
      initUI();
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
    case UIAction.savePackageConfiguration:
      savePackageConfiguration();
      break;

    case UIAction.addSuggestedReply:
      SuggestedReplyData data = actionData;
      var newSuggestedReply = new_model.SuggestedReply()
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
      (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.groups[data.groupId].addReply(newSuggestedReply.suggestedReplyId, newSuggestedReplyView);
      editedSuggestedReplies.add(newSuggestedReply.docId);
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
      editedSuggestedReplies.add(data.id);
      break;
    case UIAction.removeSuggestedReply:
      SuggestedReplyData data = actionData;
      var suggestedReply = suggestedRepliesManager.getSuggestedReplyById(data.id);
      suggestedRepliesManager.removeSuggestedReply(suggestedReply);
      (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.groups[suggestedReply.groupId].removeReply(suggestedReply.suggestedReplyId);
      // TODO: queue suggested replies for removal once the backend infrastructure can handle removing them
      break;
    case UIAction.addSuggestedReplyGroup:
      var newGroupId = suggestedRepliesManager.nextSuggestedReplyGroupId;
      suggestedRepliesManager.emptyGroups[newGroupId] = '';
      var suggestedReplyGroupView = new view.SuggestedReplyGroupView(newGroupId, suggestedRepliesManager.emptyGroups[newGroupId]);
      (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.addReplyGroup(newGroupId, suggestedReplyGroupView);
      break;
    case UIAction.updateSuggestedReplyGroup:
      SuggestedReplyGroupData data = actionData;
      suggestedRepliesManager.updateSuggestedRepliesGroupDescription(data.groupId, data.newGroupName);
      (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.groups[data.groupId].name = data.newGroupName;
      break;
    case UIAction.removeSuggestedReplyGroup:
      SuggestedReplyGroupData data = actionData;
      suggestedRepliesManager.removeSuggestedRepliesGroup(data.groupId);
      (view.contentView.renderedView as view.PackageConfiguratorView).suggestedRepliesView.removeReplyGroup(data.groupId);
      break;
    case UIAction.changeSuggestedRepliesCategory:
      SuggestedRepliesCategoryData data = actionData;
      selectedSuggestedRepliesCategory = data.category;
      _populateReplyPanelView(suggestedRepliesManager.suggestedRepliesByCategory[selectedSuggestedRepliesCategory]);
  }
}

void loadAuthView() {
  view.contentView.renderView(new view.AuthMainView());
}

void savePackageConfiguration() {
  List<new_model.SuggestedReply> repliesToSave = editedSuggestedReplies.map((suggestedReplyId) => suggestedRepliesManager.getSuggestedReplyById(suggestedReplyId)).toList();
  (view.contentView.renderedView as view.PackageConfiguratorView).showSaveStatus('Saving...');
  saveSuggestedReplies(repliesToSave).then((value) {
    (view.contentView.renderedView as view.PackageConfiguratorView).showSaveStatus('Saved!');
  }, onError: (error, stacktrace) {
    (view.contentView.renderedView as view.PackageConfiguratorView).showSaveStatus('Unable to save. Please check your connection and try again. If the issue persists, please contact your project administrator');
  });
}

void loadPackageConfigurationView() {
  var configuratorView = new view.PackageConfiguratorView();
  view.contentView.renderView(configuratorView);
}

void loadTagConfigurationView() {
  var tagConfigView = new view.TagsConfigurationView();
  view.contentView.renderView(tagConfigView);
}

Future<void> saveSuggestedReplies(List<new_model.SuggestedReply> suggestedReplies) {
  return platform.updateSuggestedReplies(suggestedReplies);
}
