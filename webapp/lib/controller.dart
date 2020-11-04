library controller;

import 'dart:html';

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;
import 'router.dart';
import 'model.dart' as model;

Logger log = new Logger('controller.dart');
Router router;

enum UIAction {
  userSignedIn,
  userSignedOut,
  signInButtonClicked,
  signOutButtonClicked,
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

class ConfigurationTagData extends Data {
  String selectedTag;
  String tagToAdd;
  ConfigurationTagData({this.selectedTag, this.tagToAdd});
}

class ConfigurationResponseData extends Data {
  String parentTag;
  String language;
  String text;
  int index;
  ConfigurationResponseData({this.parentTag, this.index, this.language, this.text});
}

Map<String, List<List<String>>> configurationTagData;
Set<String> additionalConfigurationTags;
List<String> configurationResponseLanguages;

model.User signedInUser;

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  window.location.hash = '#/dashboard'; //TODO This is just temporary initialization becuase we don't have a complete app
  router.routeTo(window.location.hash);
  view.navView.projectTitle = 'COVID IMAQAL'; //TODO To be replaced by data from model
}

void setupRoutes() {
  router = new Router()
    ..addHandler('#/auth', loadAuthView)
    ..addHandler('#/dashboard', loadDashboardView)
    ..addHandler('#/batch-replies-configuration', loadBatchRepliesConfigurationView)
    ..addHandler('#/escalates-configuration', loadEscalatesConfigurationView)
    ..addHandler('#/project-configuration', loadProjectConfigurationView)
    ..listen();
}

void command(UIAction action, Data actionData) {
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
  }
}

void loadAuthView() {
  view.contentView.renderView(new view.AuthMainView());
}

void loadDashboardView() {
  var dashboardView = new view.DashboardView();
  dashboardView.activePackages.addAll(
    [
      new view.ActivePackagesViewPartial('Urgent conversations', '#/conversations', '#/escalates-configuration'),
      new view.ActivePackagesViewPartial('Open conversations', '#/conversations', '#'),
      new view.ActivePackagesViewPartial('Batch replies (Week 12)', '', '#/batch-replies-configuration'),
    ]);
  dashboardView.availablepackages.addAll(
    [
      new view.AvailablePackagesViewPartial('Quick Poll',
        'Ask a question with fixed answers',
        ['Needs: Q/A, Labelling team, Safeguarding response', 'Produces: Dashboard for distribution of answers']),
      new view.AvailablePackagesViewPartial('Information Service',
        'Answer people\'s questions',
        ['Needs: Response protocol, Labelling team, Safeguarding response', 'Produces: Thematic distribution, work rate tracker']),
      new view.AvailablePackagesViewPartial('Bulk Message',
        'Send set of people a once off message',
        ['Needs: Definition of who. Safeguarding response', 'Produces: Success/Fail tracker'])
    ]);
  dashboardView.renderActivePackages();
  dashboardView.renderAvailablePackages();
  view.contentView.renderView(dashboardView);
}

void loadBatchRepliesConfigurationView() {
  view.contentView.renderView(new view.BatchRepliesConfigurationView(model.changeCommsPackage));
}

void loadEscalatesConfigurationView() {
  view.contentView.renderView(new view.EscalatesConfigurationView());
}

loadProjectConfigurationView() {
  view.contentView.renderView(new view.ProjectConfigurationView());
}

// Tag Operations
void _updateTag(Map<String, model.TagStyle> tagType, String tag, model.TagStyle tagStyle) {
  if (tagType.containsKey(tag)) {
    tagType.remove(tag);
    model.changeCommsPackage.tags.addAll({tag : tagStyle});
  } else {
    tagType.addAll({tag: tagStyle});
    model.changeCommsPackage.tags.remove(tag);
  }
}

void hasAllTagsChanged(String tag, model.TagStyle tagStyle) {
  _updateTag(model.changeCommsPackage.hasAllTags, tag, tagStyle);
  loadBatchRepliesConfigurationView();
}

void containsLastInTurnTagsChanged(String tag, model.TagStyle tagStyle) {
   _updateTag(model.changeCommsPackage.containsLastInTurnTags, tag, tagStyle);
  loadBatchRepliesConfigurationView();
}

void hasNoneTagsChanged(String tag, model.TagStyle tagStyle) {
   _updateTag(model.changeCommsPackage.hasNoneTags, tag, tagStyle);
  loadBatchRepliesConfigurationView();
}

void addsTagsChanged(String updatedTag, String originalTag, model.TagStyle tagStyle) {
  if (model.changeCommsPackage.addsTags.containsKey(originalTag)) {
    if (updatedTag != originalTag) {
      var addsTagsKeys = model.changeCommsPackage.addsTags.keys.toList();
      var addsTagsTagValues= model.changeCommsPackage.addsTags.values.toList();
      var originalIndex = addsTagsKeys.indexOf(originalTag);
      addsTagsKeys.removeAt(originalIndex);
      addsTagsKeys.insert(originalIndex, updatedTag);
      Map<String, model.TagStyle> updatedAddsTags = {};
      for (int i = 0; i < addsTagsKeys.length; i++) {
        updatedAddsTags[addsTagsKeys[i]] = addsTagsTagValues[i];
      }
      model.changeCommsPackage.addsTags = updatedAddsTags;
    } else {
      model.changeCommsPackage.addsTags.remove(originalTag);
    }
  } else {
    model.changeCommsPackage.addsTags.addAll({updatedTag: tagStyle});
  }
  loadBatchRepliesConfigurationView();
}

// Suggested Replies operations
void addNewResponse() {
  model.changeCommsPackage.suggestedReplies.add(
    {
      "messages":
        [
          "",
          "",
        ],
      "reviewed": false,
      "reviewed-by": "",
      "reviewed-date": ""
    },
  );
  loadBatchRepliesConfigurationView();
}

void updateResponse(int rowIndex, int colIndex, String response) {
  model.changeCommsPackage.suggestedReplies[rowIndex]['messages'][colIndex] = response;
  loadBatchRepliesConfigurationView();
}

void reviewResponse(int rowIndex, bool reviewed) {
  if (reviewed) {
    var now = DateTime.now().toLocal();
    var reviewedDate = '${now.year}-${now.month}-${now.day}';
    model.changeCommsPackage.suggestedReplies[rowIndex]['reviewed'] = true;
    model.changeCommsPackage.suggestedReplies[rowIndex]['reviewed-by'] = signedInUser.userEmail;
    model.changeCommsPackage.suggestedReplies[rowIndex]['reviewed-date'] = reviewedDate;
  } else {
    model.changeCommsPackage.suggestedReplies[rowIndex]['reviewed'] = false;
    model.changeCommsPackage.suggestedReplies[rowIndex]['reviewed-by'] = '';
    model.changeCommsPackage.suggestedReplies[rowIndex]['reviewed-date'] = '';
  }
  loadBatchRepliesConfigurationView();
}

void removeResponse(int rowIndex) {
  model.changeCommsPackage.suggestedReplies.removeAt(rowIndex);
  loadBatchRepliesConfigurationView();
}
