library controller;

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

List<String> configurationResponseLanguages;

model.User signedInUser;

ProjectData project;

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  router.routeTo('#/project-configuration');
}

void setupRoutes() {
  router = new Router()
    ..addAuthHandler(new Route('#/auth', loadAuthView))
    ..addDefaultHandler(new Route('#/dashboard', loadDashboardView))
    ..addHandler(new Route('#/project-selector', loadProjectSelectorView))
    ..addHandler(new Route('#/batch-replies-configuration', loadBatchRepliesConfigurationView))
    ..addHandler(new Route('#/escalates-configuration', loadEscalatesConfigurationView))
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
      new view.ActivePackagesViewPartial('Urgent conversations', '#/conversations', '#/escalates-configuration',  '${model.conversationData["needs-urgent-intervention"]} awaiting reply'),
      new view.ActivePackagesViewPartial('Open conversations', '#/conversations', '#', '30 open conversations'),
      new view.ActivePackagesViewPartial('Batch replies (Week 12)', '', '#/batch-replies-configuration', ''),
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

void loadBatchRepliesConfigurationView() {
  view.contentView.renderView(new view.BatchRepliesConfigurationView(model.changeCommsPackage));
}

void loadEscalatesConfigurationView() {
  view.contentView.renderView(new view.EscalatesConfigurationView());
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

void _addTag(String tag, model.TagStyle tagStyle, Map<String, model.TagStyle> tagCollection, [bool isEditable = false]) {
  tagCollection.addAll({tag: tagStyle});
  if (!isEditable) model.changeCommsPackage.availableTags.remove(tag);
}

void _updateTag(String originalTag, String updatedTag, Map<String, model.TagStyle> tagCollection) {
  if (originalTag == updatedTag) return;
  var tagKeys = tagCollection.keys.toList();
  var tagValues= tagCollection.values.toList();
  var originalIndex = tagKeys.indexOf(originalTag);
  if (originalIndex < 0) {
    _addTag(updatedTag, model.TagStyle.Normal, tagCollection);
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

void _removeTag(String tag, model.TagStyle tagStyle, Map<String, model.TagStyle> tagCollection, [bool isEditable = false]) {
  tagCollection.remove(tag);
  if (!isEditable) model.changeCommsPackage.availableTags.addAll({tag : tagStyle});
}

void hasAllTagsChanged(String tag, model.TagStyle tagStyle, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagStyle, model.changeCommsPackage.hasAllTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagStyle, model.changeCommsPackage.hasAllTags);
      break;
  }
  loadBatchRepliesConfigurationView();
}

void containsLastInTurnTagsChanged(String tag, model.TagStyle tagStyle, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagStyle, model.changeCommsPackage.containsLastInTurnTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagStyle, model.changeCommsPackage.containsLastInTurnTags);
      break;
  }
  loadBatchRepliesConfigurationView();
}

void hasNoneTagsChanged(String tag, model.TagStyle tagStyle, TagOperation tagOperation) {
   switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(tag, tagStyle, model.changeCommsPackage.hasNoneTags);
      break;
    case TagOperation.UPDATE:
      break;
    case TagOperation.REMOVE:
      _removeTag(tag, tagStyle, model.changeCommsPackage.hasNoneTags);
      break;
  }
  loadBatchRepliesConfigurationView();
}

void addsTagsChanged(String originalTag, String updatedTag, model.TagStyle tagStyle, TagOperation tagOperation) {
  switch(tagOperation) {
    case TagOperation.ADD:
      _addTag(updatedTag, tagStyle, model.changeCommsPackage.addsTags, true);
      break;
    case TagOperation.UPDATE:
      _updateTag(originalTag, updatedTag, model.changeCommsPackage.addsTags);
      break;
    case TagOperation.REMOVE:
      _removeTag(originalTag, tagStyle, model.changeCommsPackage.addsTags, true);
      break;
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

void saveProjectConfiguration(Map config) {
  model.projectConfigurationFormData = config;
  List<String> languagesAdded = config['project-languages'].keys.toList();
  model.additionalProjectConfigurationLanguages.removeWhere((l) => languagesAdded.contains(l));
  loadProjectConfigurationView();
}
