import 'dart:html';

import 'logger.dart';
import 'controller.dart' as controller;

Logger log = new Logger('view.dart');

Element get headerElement => querySelector('header');
Element get mainElement => querySelector('main');
Element get footerElement => querySelector('footer');

NavView navView;
ContentView contentView;

void init() {
  navView = new NavView();
  contentView = new ContentView();
  headerElement.append(navView.navElement);
  mainElement.append(contentView.contentElement);
}

class NavView {
DivElement navElement;
DivElement appLogos;
DivElement projectTitle;

  NavView() {
    navElement = new DivElement()
      ..classes.add('nav');
    appLogos = new DivElement()
      ..classes.add('nav__app-logo');
    projectTitle = new DivElement()
      ..classes.add('nav__project-title')
      ..append(new SpanElement()..text = 'COVID IMAQAL Batch replies (Week 12)');

    appLogos.append(new ImageElement(src: 'assets/africas-voices-logo.svg'));

    navElement.append(appLogos);
    navElement.append(projectTitle);
  }
}

class ContentView {
  DivElement contentElement;
  DashboardView dashboardView;

  ContentView() {
    contentElement = new DivElement()..classes.add('content');
    dashboardView = new DashboardView();
    dashboardView.activePackages.addAll(
      [
        new ActivePackagesViewPartial('Urgent conversations'),
        new ActivePackagesViewPartial('Open conversations'),
        new ActivePackagesViewPartial('Batch replies (Week 12)'),
      ]);
    dashboardView.availablepackages.addAll(
      [
        new AvailablePackagesViewPartial('Quick Poll',
          'Ask a question with fixed answers',
          ['Needs: Q/A, Labelling team, Safeguarding response', 'Produces: Dashboard for distribution of answers']),
        new AvailablePackagesViewPartial('Information Service',
          'Answer people\'s questions',
          ['Needs: Response protocol, Labelling ream, Safeguarding response', 'Produces: Thematic distribution, work rate tracker']),
        new AvailablePackagesViewPartial('Bulk Message',
          'Send set of people a once off message',
          ['Needs: Definition of who. Safeguarding response', 'Produces: Success/Fail tracker'])
      ]);

      dashboardView.pupolateActivePackages();
      dashboardView.pupolateAvailablePackages();
      contentElement.append(dashboardView.dashboardViewElement);
  }
}

class DashboardView {
  List<ActivePackagesViewPartial> activePackages;
  List<AvailablePackagesViewPartial> availablepackages;

  DivElement dashboardViewElement;
  DivElement activePacakgesContainer;
  DivElement availablePackagesContainer;

  DashboardView() {
    activePackages = [];
    availablepackages = [];
    dashboardViewElement = new DivElement()..classes.add('dashboard');
    activePacakgesContainer = new DivElement()
      ..classes.add('active-packages');
    availablePackagesContainer = new DivElement()
      ..classes.add('available-packages');
    dashboardViewElement.append(activePacakgesContainer);
    dashboardViewElement.append(availablePackagesContainer);
  }

  void pupolateActivePackages() {
    activePacakgesContainer.children.clear();
    activePacakgesContainer.append(new HeadingElement.h1()..text = "Active packages");
    if (activePackages.isNotEmpty) {
      activePackages.forEach((package) => activePacakgesContainer.append(package.packageElement));
    }
  }

  void pupolateAvailablePackages() {
    availablePackagesContainer.children.clear();
    availablePackagesContainer.append(new HeadingElement.h1()..text = "Add a package");
    if (activePackages.isNotEmpty) {
      availablepackages.forEach((package) => availablePackagesContainer.append(package.packageElement));
    }
  }
}

class ActivePackagesViewPartial {
  DivElement packageElement;
  HeadingElement _packageName;
  DivElement _packageActionsContainer;
  AnchorElement _dashboardAction;
  AnchorElement _conversationsAction;
  AnchorElement _configureAction;

  ActivePackagesViewPartial(String packageName) {
    packageElement = new DivElement()
      ..classes.add('active-packages__package');
    _packageName = new HeadingElement.h4()
      ..text = '$packageName (Active)';
    _packageActionsContainer = new DivElement()
      ..classes.add('active-packages__package-actions');
    _dashboardAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Dashboard'
      ..href = '#';
    _conversationsAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Conversations'
      ..href = '#';
    _configureAction= new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Configure'
      ..href = '#';
    _packageActionsContainer.append(_dashboardAction);
    _packageActionsContainer.append(_conversationsAction);
    _packageActionsContainer.append(_configureAction);
    packageElement.append(_packageName);
    packageElement.append(_packageActionsContainer);
  }
}

class AvailablePackagesViewPartial {
  DivElement packageElement;
  DivElement _addPackageLinkContainer;
  AnchorElement _addPackageLink;
  DivElement _descriptionContaner;
  HeadingElement _descriptionTitle;
  DivElement _descriptionDetails;

  AvailablePackagesViewPartial(String packageName, String descriptionTitle, List<String> descriptionDetails) {
    packageElement = new DivElement()
      ..classes.add('available-packages__package');
    _addPackageLinkContainer = new DivElement()
      ..classes.add('available-packages__add-package');
    _addPackageLink = new AnchorElement()
      ..classes.add('available-packages__add-package-link')
      ..text = packageName
      ..href = '#';
    _descriptionContaner = new DivElement()
      ..classes.add('available-packages__package-description');
    _descriptionTitle = new HeadingElement.h4()
      ..text = descriptionTitle;
    _descriptionDetails = new DivElement();
    descriptionDetails.forEach((detail) => _descriptionDetails.append(new ParagraphElement()..text = detail));

    _addPackageLinkContainer.append(_addPackageLink);
    _descriptionContaner.append(_descriptionTitle);
    _descriptionContaner.append(_descriptionDetails);
    packageElement.append(_addPackageLinkContainer);
    packageElement.append(_descriptionContaner);
  }
}
