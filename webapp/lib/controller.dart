library controller;

import 'dart:html';

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;
import 'router.dart';

Logger log = new Logger('controller.dart');
Router router;

enum UIAction {
  userSignedIn,
  loadProjectConfiguration,
  configurationTagSelected,
  addConfigurationTag,
  editConfigurationTagResponse,
  addConfigurationResponseEntries
}

class Data {}

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

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  window.location.hash = '#/dashboard'; //TODO This is just temporary initialization becuase we don't have a complete app
  router.routeTo(window.location.hash);
}

void setupRoutes() {
  router = new Router()
    ..addHandler('#/dashboard', loadDashboardView)
    ..addHandler('#/configuration', loadConfigurationView)
    ..addHandler('#/project-configuration', loadProjectConfigurationView)
    ..listen();
}

void command(UIAction action, Data actionData) {
  log.verbose('command => $action : $actionData');
  switch (action) {

    case UIAction.userSignedIn:
      initUI();
      break;
    case UIAction.loadProjectConfiguration:
      fetchConfigurationData();
      var selectedTag = configurationData.keys.toList().first;
      populateConfigurationView(selectedTag, getTagList(selectedTag, configurationTagData), configurationData[selectedTag]);
      break;
    case UIAction.configurationTagSelected:
      ConfigurationTagData data = actionData;
      populateConfigurationView(data.selectedTag, getTagList(data.selectedTag, configurationTagData), configurationData[data.selectedTag]);
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

List<String> get configurationReponseLanguageData => ['English', 'Somali'];

Set<String> get configurationTags => {'addtional Tag 1', 'addtional Tag 2', 'addtional Tag 3', 'addtional Tag 4', 'addtional Tag 5'};

Map<String, Map<String, List<String>>> get configurationData =>
  {
  'denial': {
    'English' : [
      '[denial - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[denial - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[denial - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo': {
    'English' : [
      '[rumour/stigma/misinfo - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS3] SMS3 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS4] SMS4 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - Somali SMS5] SMS5 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo - misinfo on status' : {
    'English' : [
      '[rumour/stigma/misinfo - misinfo on status - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - misinfo on status - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo - negative stigma/anger': {
    'English' : [
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS2], Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS3], Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS4], Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - negative stigma/anger - Somali SMS5], Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo - origin': {
    'English' : [
      '[rumour/stigma/misinfo - origin - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - origin - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - origin - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo - the virus discriminates': {
    'English' : [
      '[rumour/stigma/misinfo - the virus discriminates - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - the virus discriminates - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo - treatment/cure/remedy': {
    'English' : [
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - treatment/cure/remedy - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'rumour/stigma/misinfo - virus description': {
    'English' : [
      '[rumour/stigma/misinfo - virus description - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[rumour/stigma/misinfo - virus description - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[rumour/stigma/misinfo - virus description - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  },
  'somali update': {
    'English' : [
      '[somali update - English SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - English SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - English SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - English SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - English SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ],
    'Somali': [
      '[somali update - Somali SMS1] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS2] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS3] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS4] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
      '[somali update - Somali SMS5] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
    ]
  }
  };

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

loadProjectConfigurationView() {
  view.contentView.renderView(view.contentView.projectConfigurationView.configurationViewElement);
}

void fetchConfigurationData() {
  configurationTagData = configurationData;
  additionalConfigurationTags = configurationTags;
  configurationResponseLanguages = configurationReponseLanguageData;
}

Map<String, bool> getTagList(String selectedTag, Map<String, Map<String, List<String>>> tagData) {
  return new Map.fromIterable(tagData.keys.toList(),
    key: (tag) => tag,
    value: (tag) => selectedTag != null && selectedTag == tag ? true : false);
}

void populateConfigurationView(String selectedTag, Map<String, bool> tagList, Map<String, List<String>> tagResponses) {
  view.contentView.configurationView.tagList.renderTagList(tagList);
  view.contentView.configurationView.tagResponses.renderResponses(selectedTag, tagResponses);
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
