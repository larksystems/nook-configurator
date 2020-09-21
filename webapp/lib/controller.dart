library controller;

import 'dart:async';

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;

Logger log = new Logger('controller.dart');

enum UIAction {
  userSignedIn,
}

class Data {}

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

  view.contentView.configurationView.tagData = {
    'denial': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo - misinfo on status' : {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo - negative stigma/anger': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo - origin': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo - the virus discriminates': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo - treatment/cure/remedy': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'rumour/stigma/misinfo - virus description': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    },
    'somali update': {
      'English' : [
        'English SMS1',
        'English SMS2',
        'English SMS3',
        'English SMS4',
        'English SMS5'
      ],
      'Somali': [
        'Somali SMS1',
        'Somali SMS2',
        'Somali SMS3',
        'Somali SMS4',
        'Somali SMS5'
      ]
    }
  };

  view.contentView.configurationView.tagList.renderTagList(view.contentView.configurationView.tagData.keys.toList());
  Map<String, List<String>> tableData = {
      'English' : [
        'English SMS1 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in. Ut eu sagittis sem. Nulla molestie est eleifend nisl semper vehicula. Aliquam volutpat faucibus nunc, et eleifend ex blandit quis. Etiam mollis justo.',
        'English SMS2 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in. Ut eu sagittis sem. Nulla molestie est eleifend nisl semper vehicula. Aliquam volutpat faucibus nunc, et eleifend ex blandit quis. Etiam mollis justo.',
        'English SMS3 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in. Ut eu sagittis sem. Nulla molestie est eleifend nisl semper vehicula. Aliquam volutpat faucibus nunc, et eleifend ex blandit quis. Etiam mollis justo.',
        'English SMS4 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in. Ut eu sagittis sem. Nulla molestie est eleifend nisl semper vehicula. Aliquam volutpat faucibus nunc, et eleifend ex blandit quis. Etiam mollis justo.',
        'English SMS5 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in. Ut eu sagittis sem. Nulla molestie est eleifend nisl semper vehicula. Aliquam volutpat faucibus nunc, et eleifend ex blandit quis. Etiam mollis justo.'
      ],
      'Somali': [
        'Somali SMS1 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
        'Somali SMS2 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
        'Somali SMS3 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
        'Somali SMS4 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.',
        'Somali SMS5 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mollis arcu lectus, id rutrum metus dignissim in.'
      ]
    };
  view.contentView.configurationView.tagResponses.renderResponses(tableData);
  view.contentView.renderView(view.contentView.configurationView.configurationViewElement);
}



void command(UIAction action, Data actionData) {
  log.verbose('command => $action : $actionData');
  switch (action) {

    case UIAction.userSignedIn:
      initUI();
      break;
  }
}
