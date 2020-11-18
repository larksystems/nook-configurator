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
  viewProject,
  configureProject,
  loadPackageConfigurationView,
  addProject,
  addTeamMember,
  saveProjectConfiguration
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
class ProjectData extends Data {
  String projectName;
  List<String> projectMembers;

  ProjectData(this.projectName, this.projectMembers);
}

class ProjectConfigurationData extends Data {
  Map config;
  ProjectConfigurationData(this.config);
}

class PackageConfigurationData extends Data {
  String packageName;
  PackageConfigurationData(this.packageName);
}

List<String> configurationResponseLanguages;

model.User signedInUser;
ProjectData project;
String selectedPackage;

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  router.routeTo(window.location.hash);
}

void setupRoutes() {
  router = new Router()
    ..addAuthHandler(new Route('#/auth', loadAuthView))
    ..addHandler(new Route('#/dashboard', loadDashboardView))
    ..addDefaultHandler(new Route('#/project-selector', loadProjectSelectorView))
    ..addHandler(new Route('#/urgent-conversations-configuration', loadPackageConfigurationView))
    ..addHandler(new Route('#/open-conversations-configuration', loadPackageConfigurationView))
    ..addHandler(new Route('#/change-communications-configuration', loadPackageConfigurationView))
    ..addHandler(new Route('#/project-configuration', loadProjectConfigurationView))
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
    case UIAction.viewProject:
      project = actionData;
      router.routeTo('#/dashboard');
      break;
    case UIAction.configureProject:
      project = actionData;
      router.routeTo('#/project-configuration');
      break;
    case UIAction.loadPackageConfigurationView:
      PackageConfigurationData packageConfigurationData = actionData;
      selectedPackage = packageConfigurationData.packageName;
      loadPackageConfigurationView();
      break;
    case UIAction.addProject:
      break;
    case UIAction.addTeamMember:
      break;
    case UIAction.saveProjectConfiguration:
      ProjectConfigurationData projectConfigurationData = actionData;
      saveProjectConfiguration(projectConfigurationData.config);
      break;
  }
}

void loadAuthView() {
  view.contentView.renderView(new view.AuthMainView());
}

void loadProjectSelectorView() {
  view.navView.projectTitle = '';
  view.navView.projectOrganizations = model.projectOrganizations;
  view.contentView.renderView(new view.ProjectSelectorView(model.projectData, model.teamMembers));
}

void loadDashboardView() {
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  var dashboardView = new view.DashboardView(model.conversationData);
  dashboardView.activePackages.addAll(
    [
      new view.ActivePackagesViewPartial('Urgent conversations', '#/conversations', '#/urgent-conversations-configuration',  '${model.conversationData["needs-urgent-intervention"]} awaiting reply'),
      new view.ActivePackagesViewPartial('Open conversations', '#/conversations', '#/open-conversations-configuration', '30 open conversations'),
      new view.ActivePackagesViewPartial('Change Communications (Week 12)', '', '#/change-communications-configuration', ''),
    ]);
  dashboardView.availablepackages.addAll(
    [
      new view.AvailablePackagesViewPartial('Quick Poll',
        'Ask a question with fixed answers',
        {'Needs' : 'Q/A, Labelling team, Safeguarding response', 'Produces' : 'Dashboard for distribution of answers'}),
      new view.AvailablePackagesViewPartial('Information Service',
        'Answer people\'s questions',
        {'Needs' : 'Response protocol, Labelling team, Safeguarding response', 'Produces' : 'Thematic distribution, work rate tracker'}),
      new view.AvailablePackagesViewPartial('Bulk Message',
        'Send set of people a once off message',
        {'Needs' : 'Definition of who. Safeguarding response', 'Produces' : 'Success/Fail tracker'})
    ]);
  dashboardView.renderActivePackages();
  dashboardView.renderAvailablePackages();
  view.contentView.renderView(dashboardView);
}

void loadPackageConfigurationView() {
  view.PackageConfiguratorView configuratorView;
  selectedPackage = selectedPackage ?? model.packageConfigurationData.keys.toList().first;
  switch (selectedPackage) {
    case 'Change Communications':
      configuratorView = new view.ChangeCommunicationsConfigurationView(model.packageConfigurationData);
      break;
    case 'Urgent conversations':
      configuratorView = new view.UrgentConversationsConfigurationView(model.packageConfigurationData);
      break;
    case 'Open conversations':
      configuratorView = new view.UrgentConversationsConfigurationView(model.packageConfigurationData);
      break;
  }
  view.contentView.renderView(configuratorView);
}

loadProjectConfigurationView() {
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  view.contentView.renderView(new view.ProjectConfigurationView(model.projectConfigurationFormData, model.additionalProjectConfigurationLanguages));
}

// Tag Operations
enum TagOperation {
  ADD,
  UPDATE,
  REMOVE
}

void _addTag(String selectedPackage, String tag, model.TagStyle tagStyle, Map<String, model.TagStyle> tagCollection, [bool isEditable = false]) {
  tagCollection.addAll({tag: tagStyle});
  if (!isEditable) model.packageConfigurationData[selectedPackage].availableTags.remove(tag);
}

void _updateTag(String selectedPackage, String originalTag, String updatedTag, Map<String, model.TagStyle> tagCollection) {
  if (originalTag == updatedTag) return;
  var tagKeys = tagCollection.keys.toList();
  var tagValues= tagCollection.values.toList();
  var originalIndex = tagKeys.indexOf(originalTag);
  if (originalIndex < 0) {
    _addTag(selectedPackage, updatedTag, model.TagStyle.Normal, tagCollection);
    return;
  }
  tagKeys.removeAt(originalIndex);
  tagKeys.insert(originalIndex, updatedTag);
  Map<String, model.TagStyle> updatedTagCollection = {};
  for (int i = 0; i < tagKeys.length; i++) {
    updatedTagCollection[tagKeys[i]] = tagValues[i];
  }
  tagCollection.clear();
  tagCollection.addAll(updatedTagCollection);
}

void _removeTag(String selectedPackage, String tag, model.TagStyle tagStyle, Map<String, model.TagStyle> tagCollection, [bool isEditable = false]) {
  tagCollection.remove(tag);
  if (!isEditable) model.packageConfigurationData[selectedPackage].availableTags.addAll({tag : tagStyle});
}

void hasAllTagsChanged(String selectedPackage, String tag, model.TagStyle tagStyle, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(selectedPackage, tag, tagStyle, model.packageConfigurationData[selectedPackage].hasAllTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(selectedPackage, tag, tagStyle, model.packageConfigurationData[selectedPackage].hasAllTags);
      break;
  }
  loadPackageConfigurationView();
}

void containsLastInTurnTagsChanged(String selectedPackage, String tag, model.TagStyle tagStyle, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(selectedPackage, tag, tagStyle, model.packageConfigurationData[selectedPackage].containsLastInTurnTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(selectedPackage, tag, tagStyle, model.packageConfigurationData[selectedPackage].containsLastInTurnTags);
      break;
  }
  loadPackageConfigurationView();
}

void hasNoneTagsChanged(String selectedPackage, String tag, model.TagStyle tagStyle, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(selectedPackage, tag, tagStyle, model.packageConfigurationData[selectedPackage].hasNoneTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(selectedPackage, tag, tagStyle, model.packageConfigurationData[selectedPackage].hasNoneTags);
      break;
  }
  loadPackageConfigurationView();
}

void addsTagsChanged(String selectedPackage, String originalTag, String updatedTag, model.TagStyle tagStyle, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(selectedPackage, updatedTag, tagStyle, model.packageConfigurationData[selectedPackage].addsTags, true);
      break;
    case TagOperation.UPDATE:
      _updateTag(selectedPackage, originalTag, updatedTag, model.packageConfigurationData[selectedPackage].addsTags);
      break;
    case TagOperation.REMOVE:
      _removeTag(selectedPackage, originalTag, tagStyle, model.packageConfigurationData[selectedPackage].addsTags, true);
      break;
  }
  loadPackageConfigurationView();
}

// Suggested Replies operations
void addNewResponse(String selectedPackage) {
  model.packageConfigurationData[selectedPackage].suggestedReplies.add(
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
  loadPackageConfigurationView();
}

void updateResponse(String selectedPackage, int rowIndex, int colIndex, String response) {
  model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['messages'][colIndex] = response;
  loadPackageConfigurationView();
}

void reviewResponse(String selectedPackage, int rowIndex, bool reviewed) {
  if (reviewed) {
    var now = DateTime.now().toLocal();
    var reviewedDate = '${now.year}-${now.month}-${now.day}';
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed'] = true;
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-by'] = signedInUser.userEmail;
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-date'] = reviewedDate;
  } else {
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed'] = false;
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-by'] = '';
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-date'] = '';
  }
  loadPackageConfigurationView();
}

void removeResponse(String selectedPackage, int rowIndex) {
  model.packageConfigurationData[selectedPackage].suggestedReplies.removeAt(rowIndex);
  loadPackageConfigurationView();
}

void saveProjectConfiguration(Map config) {
  model.projectConfigurationFormData = config;
  List<String> languagesAdded = config['project-languages'].keys.toList();
  model.additionalProjectConfigurationLanguages.removeWhere((l) => languagesAdded.contains(l));
  loadProjectConfigurationView();
}
