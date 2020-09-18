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
  var dashboardView = new view.DashboardView();
  dashboardView.activePackages.addAll(
    [
      new view.ActivePackagesViewPartial('Urgent conversations'),
      new view.ActivePackagesViewPartial('Open conversations'),
      new view.ActivePackagesViewPartial('Batch replies (Week 12)'),
    ]);
  dashboardView.availablepackages.addAll(
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
  dashboardView.renderActivePackages();
  dashboardView.renderAvailablePackages();

  view.contentView.renderView(dashboardView.dashboardViewElement);
}



void command(UIAction action, Data actionData) {
  log.verbose('command => $action : $actionData');
  switch (action) {

    case UIAction.userSignedIn:
      initUI();
      break;
  }
}
