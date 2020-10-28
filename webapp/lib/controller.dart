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
  loadProjectConfiguration,
  loadBatchRepliesPackageConfiguration,
  loadEscalatesPackageConfiguration,
  updateBatchRepliesPackageTags,
  updateBatchRepliesPackageResponses
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

enum TagType {
  HAS_ALL_TAGS,
  CONTAINS_LAST_IN_TURN_TAGS,
  HAS_NONE_TAGS,
  ADDS_TAGS
}
class BatchRepliesPackageTagData extends Data {
  List<String> tags;
  List<String> hasAllTags;
  List<String> containsLastInTurnTags;
  List<String> hasNoneTags;
  List<String> addsTags;
  BatchRepliesPackageTagData({this.tags, this.hasAllTags, this.containsLastInTurnTags, this.hasNoneTags, this.addsTags});
}

class BatchRepliesPackageResponseData extends Data {
  List<Map> messages;
  BatchRepliesPackageResponseData([this.messages]);
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
  window.location.hash = '#/batch-replies-configuration'; //TODO This is just temporary initialization becuase we don't have a complete app
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
    case UIAction.updateBatchRepliesPackageTags:
      BatchRepliesPackageTagData data = actionData;
      updateBatchRepliesPackageTags(data);
      break;
    case UIAction.updateBatchRepliesPackageResponses:
      BatchRepliesPackageResponseData data = actionData;
      updateBatchRepliesPackageResponses(data);
      break;
    case UIAction.loadProjectConfiguration:
      // TODO: Handle this case.
      break;
    case UIAction.loadBatchRepliesPackageConfiguration:
      // TODO: Handle this case.
      break;
    case UIAction.loadEscalatesPackageConfiguration:
      // TODO: Handle this case.
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
  view.contentView.renderView(new view.BatchRepliesConfigurationView(model.changeCommsPackage, model.tags));
}

void loadEscalatesConfigurationView() {
  view.contentView.renderView(new view.EscalatesConfigurationView());
}

loadProjectConfigurationView() {
  view.contentView.renderView(new view.ProjectConfigurationView());
}

void updateBatchRepliesPackageTags(BatchRepliesPackageTagData tagData) {
  model.tags = tagData.tags;
  model.changeCommsPackage
    ..hasAllTags = tagData.hasAllTags
    ..containsLastInTurnTags = tagData.containsLastInTurnTags
    ..hasNoneTags = tagData.hasNoneTags
    ..addsTags = tagData.addsTags;
  loadBatchRepliesConfigurationView();
}

void updateBatchRepliesPackageResponses(BatchRepliesPackageResponseData responseData) {
  if (responseData == null) {
    model.messages.add(
      {
        "messages":
          [
            "",
            "",
          ],
        "reviewed": false,
        "reviewed-by": "",
        "reviewed-date": ""
      }
    );
  } else {
    model.messages = responseData.messages;
  }
  loadBatchRepliesConfigurationView();
}
