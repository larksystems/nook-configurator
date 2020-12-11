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
  String projectId;
  String projectName;
  List<String> projectMembers;

  ProjectData(this.projectId, this.projectName, this.projectMembers);
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
String selectedPackageId;
String selectedProjectId;

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
      router.routeTo('#/dashboard?project=${project.projectId}');
      break;
    case UIAction.configureProject:
      project = actionData;
      router.routeTo('#/project-configuration?project=${project.projectId}');
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
  none,
  allProjects,
  dashboard
}

void loadAuthView() {
  view.navView.showParent(NavAction.none);
  view.contentView.renderView(new view.AuthMainView());
}

void loadProjectSelectorView() {
  view.navView.showParent(NavAction.none);
  view.navView.projectTitle = '';
  view.navView.projectOrganizations = model.projectOrganizations;
  view.contentView.renderView(new view.ProjectSelectorView(model.projectData, model.teamMembers));
}

void loadDashboardView() {
  selectedProjectId = selectedProjectId ?? router.routeParams['project'];
  if (selectedProjectId == null) {
    router.routeTo("#/project-selector");
    return;
  }
  view.navView.showParent(NavAction.allProjects);
  view.navView.projectTitle = model.projectData[selectedProjectId]['name'];
  view.navView.projectOrganizations = [''];
  var dashboardView = new view.DashboardView(model.projectData[selectedProjectId]['conversationData']);
  for (var package in model.projectData[selectedProjectId]['activePackages'].values) {
    dashboardView.activePackages.add(new view.ActivePackagesViewPartial(package['id'], package['name'], package['conversationsLink'], package['configurationLink'], package['chartData']));
  }
  for (var package in model.projectData[selectedProjectId]['availablePackages']) {
    dashboardView.availablepackages.add(new view.AvailablePackagesViewPartial(package['name'], package['description'], package['details']));
  }
  dashboardView.renderActivePackages();
  dashboardView.renderAvailablePackages();
  view.contentView.renderView(dashboardView);
}

void loadPackageConfigurationView() {
  selectedProjectId = router.routeParams['project'];
  selectedPackageId = router.routeParams['package'];
  if (selectedProjectId == null && selectedPackageId == null) {
    router.routeTo("#/project-selector");
    return;
  }
  view.navView.showParent(NavAction.dashboard);
  var packages = new Map<String, String>.fromIterable(model.projectData[selectedProjectId]['activePackages'].values, key: (package) => package['id'], value: (package) => package['name']);
  var configuratorView = new view.PackageConfiguratorView(packages, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData']);
  view.contentView.renderView(configuratorView);
}

void loadProjectConfigurationView() {
  selectedProjectId = router.routeParams['project'];
  if (selectedProjectId == null) {
    router.routeTo("#/project-selector");
    return;
  }
  view.navView.showParent(NavAction.dashboard);
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  view.contentView.renderView(new view.ProjectConfigurationView(model.projectData[selectedProjectId]['projectConfiguration'], model.additionalProjectConfigurationLanguages));
}

void addPackage(String packageName) {
  var id  = generatePackageId();
  model.projectData[selectedProjectId]['activePackages'][id] = {
    'id': id,
    'name': packageName,
    'conversationsLink': '#/conversations',
    'configurationLink': '#/package-configuration?package=$id',
    'chartData': '',
    'configurationData': new model.Configuration()..availableTags = model.tags
  };
  model.projectData[selectedProjectId]['availablePackages'].removeWhere((package) => package['name'] == packageName);
}

void duplicatePackage(String packageId, String packageName) {
  var originalPackageConfiguration = model.projectData[selectedProjectId]['activePackages'][packageId]['configurationData'];
  var newId = generatePackageId();
  model.projectData[selectedProjectId]['activePackages'][newId] = {
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
  var package = model.projectData[selectedProjectId]['activePackages'][packageId];
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
  if (!isEditable) model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].availableTags.remove(tag);
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
  if (!isEditable) model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].availableTags.addAll({tag : tagType});
}

void hasAllTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.add:
      _addTag(tag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].hasAllTags);
      break;
    case TagOperation.update:
      break;
    case TagOperation.remove:
      _removeTag(tag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].hasAllTags);
      break;
  }
  router.routeTo('#/package-configuration');
}

void containsLastInTurnTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.add:
      _addTag(tag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].containsLastInTurnTags);
      break;
    case TagOperation.update:
      break;
    case TagOperation.remove:
      _removeTag(tag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].containsLastInTurnTags);
      break;
  }
  router.routeTo('#/package-configuration');
}

void hasNoneTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.add:
      _addTag(tag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].hasNoneTags);
      break;
    case TagOperation.update:
      break;
    case TagOperation.remove:
      _removeTag(tag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].hasNoneTags);
      break;
  }
  router.routeTo('#/package-configuration');
}

void addsTagsChanged(String originalTag, String updatedTag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.add:
      _addTag(updatedTag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].addsTags, true);
      break;
    case TagOperation.update:
      _updateTag(originalTag, updatedTag, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].addsTags);
      break;
    case TagOperation.remove:
      _removeTag(originalTag, tagType, model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].addsTags, true);
      break;
  }
  router.routeTo('#/package-configuration');
}

// Suggested Replies operations
void addNewResponse() {
  model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies.add(
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
  router.routeTo('#/package-configuration');
}

void updateResponse(int rowIndex, int colIndex, String response) {
  model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['messages'][colIndex] = response;
  router.routeTo('#/package-configuration');
}

void reviewResponse(int rowIndex, bool reviewed) {
  if (reviewed) {
    var now = DateTime.now().toLocal();
    var reviewedDate = '${now.year}-${now.month}-${now.day}';
    model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['reviewed'] = true;
    model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['reviewed-by'] = signedInUser.userEmail;
    model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['reviewed-date'] = reviewedDate;
  } else {
    model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['reviewed'] = false;
    model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['reviewed-by'] = '';
    model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies[rowIndex]['reviewed-date'] = '';
  }
  router.routeTo('#/package-configuration');
}

void removeResponse(int rowIndex) {
  model.projectData[selectedProjectId]['activePackages'][selectedPackageId]['configurationData'].suggestedReplies.removeAt(rowIndex);
  router.routeTo('#/package-configuration');
}

void saveProjectConfiguration(Map config) {
  model.projectData[selectedProjectId]['projectConfiguration'] = config;
  List<String> languagesAdded = config['project-languages'].keys.toList();
  model.additionalProjectConfigurationLanguages.removeWhere((l) => languagesAdded.contains(l));
  router.routeTo('#/project-configuration');
}

void savePackageConfiguration() {}

// Helper Mehods

String generateProjectId() => 'project-${new Uuid().v4().split('-')[0]}';

String generatePackageId() => 'package-${new Uuid().v4().split('-')[0]}';
