library controller;

import 'dart:html';

import 'package:uuid/uuid.dart';

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
  duplicatePackage,
  editActivePackage,
  loadPackageConfigurationView,
  addProject,
  addTeamMember,
  saveProjectConfiguration,
  savePackageConfiguration,
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
  String packageId;
  String originalPackageName;
  String updatedPackageName;
  PackageConfigurationData(this.packageId, this.originalPackageName, [this.updatedPackageName]);
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
      addPackage(packageConfigurationData.originalPackageName);
      break;
    case UIAction.duplicatePackage:
      PackageConfigurationData packageConfigurationData = actionData;
      duplicatePackage(packageConfigurationData.packageId, packageConfigurationData.originalPackageName);
      break;
    case UIAction.editActivePackage:
      PackageConfigurationData packageConfigurationData = actionData;
      editActivePackage(packageConfigurationData.packageId, packageConfigurationData.originalPackageName, packageConfigurationData.updatedPackageName);
      break;
    case UIAction.loadPackageConfigurationView:
      PackageConfigurationData packageConfigurationData = actionData;
      router.routeTo('#/package-configuration?package=${packageConfigurationData.packageId}');
      break;
    case UIAction.addProject:
      break;
    case UIAction.addTeamMember:
      break;
    case UIAction.saveProjectConfiguration:
      ProjectConfigurationData projectConfigurationData = actionData;
      saveProjectConfiguration(projectConfigurationData.config);
      break;
    case UIAction.savePackageConfiguration:
      savePackageConfiguration();
      break;
  }
}

enum NavAction {
  allProjects,
  dashboard
}

void loadAuthView() {
  view.navView.navActions[NavAction.allProjects](false);
  view.navView.navActions[NavAction.dashboard](false);
  view.contentView.renderView(new view.AuthMainView());
}

void loadProjectSelectorView() {
  view.navView.navActions[NavAction.allProjects](false);
  view.navView.navActions[NavAction.dashboard](false);
  view.navView.projectTitle = '';
  view.navView.projectOrganizations = model.projectOrganizations;
  view.contentView.renderView(new view.ProjectSelectorView(model.projectData, model.teamMembers));
}

void loadDashboardView() {
  view.navView.navActions[NavAction.allProjects](true);
  view.navView.navActions[NavAction.dashboard](false);
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  var dashboardView = new view.DashboardView(model.conversationData);
  for (var package in model.activePackages.values) {
    dashboardView.activePackages.add(new view.ActivePackagesViewPartial(package['id'], package['name'], package['conversationsLink'], package['configurationLink'], package['chartData']));
  }
  for (var package in model.availablePackages) {
    dashboardView.availablepackages.add(new view.AvailablePackagesViewPartial(package['name'], package['description'], package['details']));
  }
  dashboardView.renderActivePackages();
  dashboardView.renderAvailablePackages();
  view.contentView.renderView(dashboardView);
}

void loadPackageConfigurationView() {
  view.navView.navActions[NavAction.allProjects](false);
  view.navView.navActions[NavAction.dashboard](true);
  var packages = new Map<String, String>.fromIterable(model.activePackages.values, key: (package) => package['id'], value: (package) => package['name']);
  selectedPackage = router.routeParams['package'];
  var configuratorView = new view.PackageConfiguratorView(packages, _findActivePackageConfigurationById(selectedPackage));
  view.contentView.renderView(configuratorView);
}

loadProjectConfigurationView() {
  view.navView.navActions[NavAction.allProjects](false);
  view.navView.navActions[NavAction.dashboard](true);
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  view.contentView.renderView(new view.ProjectConfigurationView(model.projectConfigurationFormData, model.additionalProjectConfigurationLanguages));
}

void addPackage(String packageName) {
  var id  = generatePackageId;
  model.activePackages[id] = {
    'id': id,
    'name': packageName,
    'conversationsLink': '#/conversations',
    'configurationLink': '#/package-configuration?package=$id',
    'chartData': '',
    'configurationData': new model.Configuration()..availableTags = model.tags
  };
  model.availablePackages.removeWhere((package) => package['name'] == packageName);
}

void duplicatePackage(String packageId, String packageName) {
  var originalPackageConfiguration = _findActivePackageConfigurationById(packageId);
  var newId = generatePackageId;
  model.activePackages[newId] = {
    'id': newId,
    'name': '$packageName [COPY]',
    'conversationsLink': '#/conversations',
    'configurationLink': '#/package-configuration?package=$newId',
    'chartData': '',
    'configurationData': new model.Configuration()
      ..availableTags = new Map.from(originalPackageConfiguration.availableTags)
      ..hasAllTags = new Map.from(originalPackageConfiguration.hasAllTags)
      ..containsLastInTurnTags = new Map.from(originalPackageConfiguration.containsLastInTurnTags)
      ..hasNoneTags = new Map.from(originalPackageConfiguration.hasNoneTags)
      ..suggestedReplies = new List.from(originalPackageConfiguration.suggestedReplies)
      ..addsTags = new Map.from(originalPackageConfiguration.addsTags)
  };
  router.routeTo(window.location.hash);
}

void editActivePackage(String packageId, String originalPackageName, updatedPackageName) {
  if (originalPackageName == updatedPackageName) return;
  var package = _findActivePackageById(packageId);
  package['name'] = updatedPackageName;
  router.routeTo(window.location.hash);
}

// Tag Operations
enum TagOperation {
  add,
  update,
  remove
}

void _addTag(String tag, model.TagType tagType, Map<String, model.TagType> tagCollection, [bool isEditable = false]) {
  tagCollection.addAll({tag: tagType});
  if (!isEditable) _findActivePackageConfigurationById(selectedPackage).availableTags.remove(tag);
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
  if (!isEditable) _findActivePackageConfigurationById(selectedPackage).availableTags.addAll({tag : tagType});
}

void hasAllTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.add:
      _addTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasAllTags);
      break;
    case TagOperation.update:
      break;
    case TagOperation.remove:
      _removeTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasAllTags);
      break;
  }
  loadPackageConfigurationView();
}

void containsLastInTurnTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.add:
      _addTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).containsLastInTurnTags);
      break;
    case TagOperation.update:
      break;
    case TagOperation.remove:
      _removeTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).containsLastInTurnTags);
      break;
  }
  loadPackageConfigurationView();
}

void hasNoneTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.add:
      _addTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasNoneTags);
      break;
    case TagOperation.update:
      break;
    case TagOperation.remove:
      _removeTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasNoneTags);
      break;
  }
  loadPackageConfigurationView();
}

void addsTagsChanged(String originalTag, String updatedTag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.add:
      _addTag(updatedTag, tagType, _findActivePackageConfigurationById(selectedPackage).addsTags, true);
      break;
    case TagOperation.update:
      _updateTag(originalTag, updatedTag, _findActivePackageConfigurationById(selectedPackage).addsTags);
      break;
    case TagOperation.remove:
      _removeTag(originalTag, tagType, _findActivePackageConfigurationById(selectedPackage).addsTags, true);
      break;
  }
  loadPackageConfigurationView();
}

// Suggested Replies operations
void addNewResponse() {
  _findActivePackageConfigurationById(selectedPackage).suggestedReplies.add(
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
  _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['messages'][colIndex] = response;
  loadPackageConfigurationView();
}

void reviewResponse(int rowIndex, bool reviewed) {
  if (reviewed) {
    var now = DateTime.now().toLocal();
    var reviewedDate = '${now.year}-${now.month}-${now.day}';
    _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['reviewed'] = true;
    _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['reviewed-by'] = signedInUser.userEmail;
    _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['reviewed-date'] = reviewedDate;
  } else {
    _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['reviewed'] = false;
    _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['reviewed-by'] = '';
    _findActivePackageConfigurationById(selectedPackage).suggestedReplies[rowIndex]['reviewed-date'] = '';
  }
  loadPackageConfigurationView();
}

void removeResponse(int rowIndex) {
  _findActivePackageConfigurationById(selectedPackage).suggestedReplies.removeAt(rowIndex);
  loadPackageConfigurationView();
}

void saveProjectConfiguration(Map config) {
  model.projectConfigurationFormData = config;
  List<String> languagesAdded = config['project-languages'].keys.toList();
  model.additionalProjectConfigurationLanguages.removeWhere((l) => languagesAdded.contains(l));
  loadProjectConfigurationView();
}

void savePackageConfiguration() {}

// Helper Mehods

Map _findActivePackageById(String packageId) {
  return model.activePackages[packageId];
}

model.Configuration _findActivePackageConfigurationById(String packageId) {
  return model.activePackages[packageId]['configurationData'];
}

String get generatePackageId => 'package-${new Uuid().v4().split('-')[0]}';
