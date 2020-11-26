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
  addPackage,
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
    ..addHandler(new Route('#/package-configuration', loadPackageConfigurationView))
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
    case UIAction.addPackage:
      PackageConfigurationData packageConfigurationData = actionData;
      addPackage(packageConfigurationData.packageName);
      break;
    case UIAction.loadPackageConfigurationView:
      PackageConfigurationData packageConfigurationData = actionData;
      router.routeTo('#/package-configuration?package=${packageConfigurationData.packageName}');
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
  for (var package in model.activePackages) {
    dashboardView.activePackages.add(new view.ActivePackagesViewPartial(package['name'], package['conversationsLink'], package['configurationLink'], package['chartData']));
  }
  for (var package in model.availablePackages) {
    dashboardView.availablepackages.add(new view.AvailablePackagesViewPartial(package['name'], package['description'], package['details']));
  }
  dashboardView.renderActivePackages();
  dashboardView.renderAvailablePackages();
  view.contentView.renderView(dashboardView);
}

void loadPackageConfigurationView() {
  var packages = model.packageConfigurationData.keys.toList();
  selectedPackage = router.routeParams['package'];
  var configuratorView = new view.PackageConfiguratorView(packages, model.packageConfigurationData[selectedPackage]);
  view.contentView.renderView(configuratorView);
}

loadProjectConfigurationView() {
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  view.contentView.renderView(new view.ProjectConfigurationView(model.projectConfigurationFormData, model.additionalProjectConfigurationLanguages));
}

void addPackage(String packageName) {
  model.packageConfigurationData[packageName] = new model.Configuration()
    ..availableTags = model.tags;
  model.activePackages.add({'name': packageName, 'conversationsLink': '#/conversations', 'configurationLink': '#/package-configuration?package=$packageName',  'chartData': ''});
  model.availablePackages.removeWhere((package) => package['name'] == packageName);
}

// Tag Operations
enum TagOperation {
  ADD,
  UPDATE,
  REMOVE
}

void _addTag(String tag, model.TagType tagType, Map<String, model.TagType> tagCollection, [bool isEditable = false]) {
  tagCollection.addAll({tag: tagType});
  if (!isEditable) model.packageConfigurationData[selectedPackage].availableTags.remove(tag);
}

void _updateTag(String originalTag, String updatedTag, Map<String, model.TagType> tagCollection) {
  if (originalTag == updatedTag) return;
  var tagKeys = tagCollection.keys.toList();
  var tagValues= tagCollection.values.toList();
  var originalIndex = tagKeys.indexOf(originalTag);
  if (originalIndex < 0) {
    _addTag(updatedTag, model.TagType.Normal, tagCollection);
    return;
  }
  tagKeys.removeAt(originalIndex);
  tagKeys.insert(originalIndex, updatedTag);
  Map<String, model.TagType> updatedTagCollection = {};
  for (int i = 0; i < tagKeys.length; i++) {
    updatedTagCollection[tagKeys[i]] = tagValues[i];
  }
  tagCollection.clear();
  tagCollection.addAll(updatedTagCollection);
}

void _removeTag(String tag, model.TagType tagType, Map<String, model.TagType> tagCollection, [bool isEditable = false]) {
  tagCollection.remove(tag);
  if (!isEditable) model.packageConfigurationData[selectedPackage].availableTags.addAll({tag : tagType});
}

void hasAllTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagType, model.packageConfigurationData[selectedPackage].hasAllTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagType, model.packageConfigurationData[selectedPackage].hasAllTags);
      break;
  }
  loadPackageConfigurationView();
}

void containsLastInTurnTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagType, model.packageConfigurationData[selectedPackage].containsLastInTurnTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagType, model.packageConfigurationData[selectedPackage].containsLastInTurnTags);
      break;
  }
  loadPackageConfigurationView();
}

void hasNoneTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagType, model.packageConfigurationData[selectedPackage].hasNoneTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagType, model.packageConfigurationData[selectedPackage].hasNoneTags);
      break;
  }
  loadPackageConfigurationView();
}

void addsTagsChanged(String originalTag, String updatedTag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(updatedTag, tagType, model.packageConfigurationData[selectedPackage].addsTags, true);
      break;
    case TagOperation.UPDATE:
      _updateTag(originalTag, updatedTag, model.packageConfigurationData[selectedPackage].addsTags);
      break;
    case TagOperation.REMOVE:
      _removeTag(originalTag, tagType, model.packageConfigurationData[selectedPackage].addsTags, true);
      break;
  }
  loadPackageConfigurationView();
}

// Suggested Replies operations
void addNewResponse() {
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

void updateResponse(int rowIndex, int colIndex, String response) {
  model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['messages'][colIndex] = response;
  loadPackageConfigurationView();
}

void reviewResponse(int rowIndex, bool reviewed) {
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

void removeResponse(int rowIndex) {
  model.packageConfigurationData[selectedPackage].suggestedReplies.removeAt(rowIndex);
  loadPackageConfigurationView();
}

void saveProjectConfiguration(Map config) {
  model.projectConfigurationFormData = config;
  List<String> languagesAdded = config['project-languages'].keys.toList();
  model.additionalProjectConfigurationLanguages.removeWhere((l) => languagesAdded.contains(l));
  loadProjectConfigurationView();
}
