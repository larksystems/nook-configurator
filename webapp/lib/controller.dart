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
    ..addHandler('#/configuration', loadConfigurationView)
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
      var selectedTag = configurationData.keys.toList().first;
      populateConfigurationView(selectedTag, getTagList(selectedTag, configurationTagData), configurationResponseLanguages, configurationTagData[selectedTag]);
      break;
    case UIAction.configurationTagSelected:
      ConfigurationTagData data = actionData;
      populateConfigurationView(data.selectedTag, getTagList(data.selectedTag, configurationTagData), configurationResponseLanguages, configurationTagData[data.selectedTag]);
      break;
    case UIAction.addConfigurationTag:
      ConfigurationTagData data = actionData;
      addNewConfigurationTag(data.tagToAdd, configurationResponseLanguages, additionalConfigurationTags, configurationTagData);
      break;
    case UIAction.editConfigurationTagResponse:
      ConfigurationResponseData data = actionData;
      updateEditedConfigurationTagResponse(data.parentTag, data.index, configurationResponseLanguages.indexOf(data.language), data.text, configurationTagData[data.parentTag]);
      break;
    case UIAction.addConfigurationResponseEntries:
      ConfigurationResponseData data = actionData;
      addConfigurationResponseEntries(data.parentTag, configurationResponseLanguages.indexOf(data.language), data.text, configurationResponseLanguages, configurationTagData);
      break;
  }
}

List<String> get configurationReponseLanguageData => ['English', 'Somali'];

Set<String> get configurationTags => {'addtional Tag 1', 'addtional Tag 2', 'addtional Tag 3', 'addtional Tag 4', 'addtional Tag 5'};

Map<String, List<List<String>>> get configurationData =>
  {
  'denial': [
    [
      '[denial - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[denial - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[denial - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[denial - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[denial - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo': [
    [
      '[rumour/stigma/misinfo - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo - misinfo on status' : [
    [
      '[rumour/stigma/misinfo - misinfo on status - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - misinfo on status - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - misinfo on status - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - misinfo on status - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - misinfo on status - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo - negative stigma/anger': [
    [
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo - origin': [
    [
      '[rumour/stigma/misinfo - origin - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - origin - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - origin - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - origin - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - origin - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo - the virus discriminates': [
    [
      '[rumour/stigma/misinfo - the virus discriminates - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - the virus discriminates - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - the virus discriminates - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - the virus discriminates - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - the virus discriminates - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo - treatment/cure/remedy': [
    [
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'rumour/stigma/misinfo - virus description': [
    [
      '[rumour/stigma/misinfo - virus description - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - virus description - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - virus description - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - virus description - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[rumour/stigma/misinfo - virus description - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ],
  'somali update': [
    [
      '[somali update - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[somali update - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[somali update - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[somali update - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    [
      '[somali update - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  ]
  };

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

loadConfigurationView() {
  view.contentView.renderView(view.contentView.configurationView.configurationViewElement);
  command(UIAction.loadProjectConfiguration, null);
}

void fetchConfigurationData() {
  configurationTagData = configurationData;
  additionalConfigurationTags = configurationTags;
  configurationResponseLanguages = configurationReponseLanguageData;
}

Map<String, bool> getTagList(String selectedTag, Map<String, List<List<String>>> tagData) {
  return new Map.fromIterable(tagData.keys.toList(),
    key: (tag) => tag,
    value: (tag) => selectedTag != null && selectedTag == tag ? true : false);
}

void populateConfigurationView(String selectedTag, Map<String, bool> tagList, List<String> responseLanguages, List<List<String>> tagResponses) {
  view.contentView.configurationView.tagList.renderTagList(tagList);
  view.contentView.configurationView.tagResponses.renderResponses(selectedTag, responseLanguages, tagResponses);
}

void addNewConfigurationTag(String tagToAdd, List<String> availableLanguages, Set<String> additionalTags, Map<String, List<List<String>>> tagData) {
  tagData[tagToAdd] = [configurationResponseLanguages.map((e) => '').toList()];
  additionalTags.remove(tagToAdd);
  populateConfigurationView(tagToAdd, getTagList(tagToAdd, tagData), availableLanguages, tagData[tagToAdd]);
}

void updateEditedConfigurationTagResponse(String parentTag, int textIndex, int languageIndex, String text, List<List<String>> tagResponses) {
  tagResponses[textIndex][languageIndex] = text;
}

void addConfigurationResponseEntries(String parentTag, int languageIndex, String text, List<String> responseLanguages, Map<String, List<List<String>>> tagData) {
  if (languageIndex != null && text != null) {
    var pos = tagData[parentTag].indexWhere((x)=> x.contains(''));
    if (pos > -1) {
      tagData[parentTag][pos][languageIndex] = text;
    } else {
      tagData[parentTag].add(configurationResponseLanguages.map((e) => '').toList());
      tagData[parentTag].last[languageIndex]= text;
    }
  } else {
    tagData[parentTag].add(['', '']);
  }
  populateConfigurationView(parentTag, getTagList(parentTag, tagData), responseLanguages,  tagData[parentTag]);
}
