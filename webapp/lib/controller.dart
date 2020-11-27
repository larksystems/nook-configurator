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
    case UIAction.saveProjectConfiguration:
      savePackageConfiguration();
      break;
  }
}

enum NavAction {
  ALLPROJECTS,
  DASHBOARD
}

void _toggleNavActions(NavAction navAction, bool show) {
  switch (navAction) {
    case NavAction.ALLPROJECTS:
      view.navView.allProjectsLink.classes.toggle('nav-links__link--show', show);
      break;
    case NavAction.DASHBOARD:
      view.navView.dashboardLink.classes.toggle('nav-links__link--show', show);
      break;
  }
}

void loadAuthView() {
  _toggleNavActions(NavAction.ALLPROJECTS, false);
  _toggleNavActions(NavAction.DASHBOARD, false);
  view.contentView.renderView(new view.AuthMainView());
}

void loadProjectSelectorView() {
  _toggleNavActions(NavAction.ALLPROJECTS, false);
  _toggleNavActions(NavAction.DASHBOARD, false);
  view.navView.projectTitle = '';
  view.navView.projectOrganizations = model.projectOrganizations;
  view.contentView.renderView(new view.ProjectSelectorView(model.projectData, model.teamMembers));
}

void loadDashboardView() {
  _toggleNavActions(NavAction.ALLPROJECTS, true);
  _toggleNavActions(NavAction.DASHBOARD, false);
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  var dashboardView = new view.DashboardView(model.conversationData);
  for (var package in model.activePackages) {
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
  _toggleNavActions(NavAction.ALLPROJECTS, false);
  _toggleNavActions(NavAction.DASHBOARD, true);
  var packages = new List<Map<String, String>>.from(model.activePackages.map((package) => new Map<String, String>.from({'id': package['id'], 'name': package['name']})));
  selectedPackage = router.routeParams['package'];
  var configuratorView = new view.PackageConfiguratorView(packages, _findActivePackageConfigurationById(selectedPackage));
  view.contentView.renderView(configuratorView);
}

loadProjectConfigurationView() {
  _toggleNavActions(NavAction.ALLPROJECTS, false);
  _toggleNavActions(NavAction.DASHBOARD, true);
  view.navView.projectTitle = project?.projectName;
  view.navView.projectOrganizations = [''];
  view.contentView.renderView(new view.ProjectConfigurationView(model.projectConfigurationFormData, model.additionalProjectConfigurationLanguages));
}

void addPackage(String packageName) {
  var id  = 'package-${new Uuid().v4().split('-')[0]}';
  model.activePackages.add(
    {
      'id': id,
      'name': packageName,
      'conversationsLink': '#/conversations',
      'configurationLink': '#/package-configuration?package=$id',
      'chartData': '',
      'configurationData': new model.Configuration().availableTags = model.tags
    }
  );
  model.availablePackages.removeWhere((package) => package['name'] == packageName);
}

void duplicatePackage(String packageId, String packageName) {
  var originalPackageConfiguration = _findActivePackageConfigurationById(packageId);
  var newId = 'package-${new Uuid().v4().split('-')[0]}';
  model.activePackages.add(
    {
      'id': newId,
      'name': '$packageName [COPY]',
      'conversationsLink': '#/conversations',
      'configurationLink': '#/package-configuration?package=$newId',
      'chartData': '',
      'configurationData': new model.Configuration()
        ..availableTags = originalPackageConfiguration.availableTags
        ..hasAllTags = originalPackageConfiguration.hasAllTags
        ..containsLastInTurnTags = originalPackageConfiguration.containsLastInTurnTags
        ..hasNoneTags = originalPackageConfiguration.hasNoneTags
        ..suggestedReplies = originalPackageConfiguration.suggestedReplies
        ..addsTags = originalPackageConfiguration.addsTags
    });
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
  ADD,
  UPDATE,
  REMOVE
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
    case TagOperation.ADD:
      _addTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasAllTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasAllTags);
      break;
  }
  loadPackageConfigurationView();
}

void containsLastInTurnTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).containsLastInTurnTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).containsLastInTurnTags);
      break;
  }
  loadPackageConfigurationView();
}

void hasNoneTagsChanged(String tag, model.TagType tagType, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasNoneTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagType, _findActivePackageConfigurationById(selectedPackage).hasNoneTags);
      break;
  }
  loadPackageConfigurationView();
}

void addsTagsChanged(String originalTag, String updatedTag, model.TagType tagType, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(updatedTag, tagType, _findActivePackageConfigurationById(selectedPackage).addsTags, true);
      break;
    case TagOperation.UPDATE:
      _updateTag(originalTag, updatedTag, _findActivePackageConfigurationById(selectedPackage).addsTags);
      break;
    case TagOperation.REMOVE:
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
  return model.activePackages.singleWhere((package) =>  package['id'] == packageId, orElse: null);
}

model.Configuration _findActivePackageConfigurationById(String packageId) {
  return model.activePackages.singleWhere((package) =>  package['id'] == packageId, orElse: null)['configurationData'];
}
