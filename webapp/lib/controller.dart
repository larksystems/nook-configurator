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
  configurationTagSelected,
  addConfigurationTag,
  editConfigurationTagResponse,
  addConfigurationResponseEntries
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

Map<String, Map<String, List<String>>> configurationTagData;
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
    case UIAction.loadProjectConfiguration:
      fetchConfigurationData();
      var selectedTag = configurationTagData.keys.toList().first;
      populateConfigurationView(selectedTag, getTagList(selectedTag, configurationTagData), configurationTagData[selectedTag]);
      break;
    case UIAction.loadBatchRepliesPackageConfiguration:
      fetchConfigurationData();
      var selectedTag = configurationTagData.keys.toList().first;
      populateConfigurationView(selectedTag, getTagList(selectedTag, configurationTagData), configurationTagData[selectedTag]);
      break;
    case UIAction.loadEscalatesPackageConfiguration:
      fetchConfigurationData(); //TODO For now fetch from the same tag data. Escalates to use a new set of tags
      var selectedTag = configurationTagData.keys.toList().first;
      populateConfigurationView(selectedTag, getTagList(selectedTag, configurationTagData), configurationTagData[selectedTag]);
      break;
    case UIAction.configurationTagSelected:
      ConfigurationTagData data = actionData;
      populateConfigurationView(data.selectedTag, getTagList(data.selectedTag, configurationTagData), configurationTagData[data.selectedTag]);
      break;
    case UIAction.addConfigurationTag:
      ConfigurationTagData data = actionData;
      addNewConfigurationTag(data.tagToAdd, configurationResponseLanguages, additionalConfigurationTags, configurationTagData);
      break;
    case UIAction.editConfigurationTagResponse:
      ConfigurationResponseData data = actionData;
      updateEditedConfigurationTagResponse(data.parentTag, data.index, data.language, data.text);
      break;
    case UIAction.addConfigurationResponseEntries:
      ConfigurationResponseData data = actionData;
      addConfigurationResponseEntries(data.parentTag, data.language, data.text, configurationTagData);
      break;
  }
}

void loadAuthView() {
  view.contentView.renderView(view.contentView.authMainView.authElement);
}

void loadDashboardView() {
  view.contentView.dashboardView.activePackages.addAll(
    [
      new view.ActivePackagesViewPartial('Urgent conversations'),
      new view.ActivePackagesViewPartial('Open conversations'),
      new view.ActivePackagesViewPartial('Batch replies (Week 12)'),
    ]);
  view.contentView.dashboardView.availablepackages.addAll(
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
  view.contentView.dashboardView.renderActivePackages();
  view.contentView.dashboardView.renderAvailablePackages();
  view.contentView.renderView(view.contentView.dashboardView.dashboardViewElement);
}

void loadBatchRepliesConfigurationView() {
  view.contentView.renderView(view.contentView.batchRepliesConfigurationView.configurationViewElement);
  command(UIAction.loadBatchRepliesPackageConfiguration, null);
}

void loadEscalatesConfigurationView() {
  view.contentView.renderView(view.contentView.escalatesConfigurationView.configurationViewElement);
  command(UIAction.loadEscalatesPackageConfiguration, null);
}

loadProjectConfigurationView() {
  view.contentView.renderView(view.contentView.projectConfigurationView.configurationViewElement);
}

void fetchConfigurationData() {
  configurationTagData = model.configurationData;
  additionalConfigurationTags = model.configurationTags;
  configurationResponseLanguages = model.configurationReponseLanguageData;
}

Map<String, bool> getTagList(String selectedTag, Map<String, Map<String, List<String>>> tagData) {
  return new Map.fromIterable(tagData.keys.toList(),
    key: (tag) => tag,
    value: (tag) => selectedTag != null && selectedTag == tag ? true : false);
}

void populateConfigurationView(String selectedTag, Map<String, bool> tagList, Map<String, List<String>> tagResponses) {
  view.contentView.batchRepliesConfigurationView.tagList.renderTagList(tagList);
  view.contentView.batchRepliesConfigurationView.tagResponses.renderResponses(selectedTag, tagResponses);

  view.contentView.escalatesConfigurationView.tagList.renderTagList(tagList);
  view.contentView.escalatesConfigurationView.tagResponses.renderResponses(selectedTag, tagResponses);
}

void addNewConfigurationTag(String tagToAdd, List<String> availableLanguages, Set<String> additionalTags, Map<String, Map<String, List<String>>> tagData) {
  tagData[tagToAdd] = new Map.fromIterable(availableLanguages, key: (d) => d, value: (d) => ['']);
  additionalTags.remove(tagToAdd);
  populateConfigurationView(tagToAdd, getTagList(tagToAdd, tagData), tagData[tagToAdd]);
}

void updateEditedConfigurationTagResponse(String parentTag, int index, String language, String text) {
  configurationTagData[parentTag][language][index]= text;
}

void addConfigurationResponseEntries(String parentTag, String language, String text, Map<String, Map<String, List<String>>> tagData) {
  if (language != null && text != null) {
    var pos = tagData[parentTag][language].indexOf('');
    if (pos > -1) {
      tagData[parentTag][language][pos] = text;
    } else {
      tagData[parentTag].forEach((k, v) => v.add(''));
      tagData[parentTag][language].last = text;
    }
  } else {
    tagData[parentTag].forEach((k, v) => v.add(''));
  }
  populateConfigurationView(parentTag, getTagList(parentTag, tagData), tagData[parentTag]);
}
