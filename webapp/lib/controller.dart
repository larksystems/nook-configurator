library controller;

import 'dart:async';

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;

Map<String, Map<String, List<String>>> tagData = {
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

Logger log = new Logger('controller.dart');

String selectedConfigurationTag ;

enum UIAction {
  userSignedIn,
  configurationTagSelected,
  addNewConfigurationTagResponseLangauge
}

class Data {}

class ConfigurationData extends Data {
  String selectedTag;
  String languageToAdd;
  ConfigurationData({this.selectedTag, this.languageToAdd});
}

void init() async {
  view.init();
  await platform.init();
}

void initUI() {
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

  //view.contentView.renderView(view.contentView.dashboardView.dashboardViewElement);

  view.contentView.configurationView.tagList.renderTagList(tagData.keys.toList());
  view.contentView.configurationView.tagResponses.renderResponses(tagData.values.toList().first);
  view.contentView.renderView(view.contentView.configurationView.configurationViewElement);
}

void command(UIAction action, Data actionData) {
  log.verbose('command => $action : $actionData');
  switch (action) {

    case UIAction.userSignedIn:
      initUI();
      break;
    case UIAction.configurationTagSelected:
      ConfigurationData data = actionData;
      retrieveTagResponse(data.selectedTag);
      break;
    case UIAction.addNewConfigurationTagResponseLangauge:
      ConfigurationData data = actionData;
      addNewConfigurationTagResponseLangauge(data.languageToAdd);
      break;
  }
}

void retrieveTagResponse(String selectedTag) {
  selectedConfigurationTag = selectedTag;
  var filteredTagResponses = Map<String, Map<String, List<String>>>.from(tagData)..removeWhere((k, v) => !k.contains(selectedTag));
  view.contentView.configurationView.tagResponses.renderResponses(filteredTagResponses.values.toList().first);
}

void addNewConfigurationTagResponseLangauge(String languageToAdd) {
  if (selectedConfigurationTag == null) {
    selectedConfigurationTag = tagData.keys.toList().first;
  }
  tagData[selectedConfigurationTag][languageToAdd] = [];
  retrieveTagResponse(selectedConfigurationTag);
}
