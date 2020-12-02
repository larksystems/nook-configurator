import 'dart:convert';
import 'dart:html';

import 'model.dart' as model;

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
  headerElement.append(navView.navViewElement);
  mainElement.append(contentView.contentViewElement);
}

class NavView {
  DivElement navViewElement;
  DivElement _appLogos;
  DivElement _navLinks;
  DivElement _projectTitle;
  DivElement _projectOrganizations;
  AuthHeaderViewPartial authHeaderViewPartial;
  AnchorElement _dashboardLink;
  AnchorElement _allProjectsLink;

  NavView() {
    navViewElement = new DivElement()
      ..classes.add('nav');
    _appLogos = new DivElement()
      ..classes.add('nav__app-logo')
      ..append(new ImageElement(src: 'assets/africas-voices-logo.svg'));
    _dashboardLink = new AnchorElement()
      ..classes.add('nav-links__link')
      ..href = '#/dashboard'
      ..text = 'Dashboard';
    _allProjectsLink = new AnchorElement()
      ..classes.add('nav-links__link')
      ..href = '#/project-selector'
      ..text = 'All projects';
    _navLinks = new DivElement()
      ..classes.add('nav-links')
      ..append(_dashboardLink)
      ..append(_allProjectsLink);
    _projectTitle = new DivElement()
      ..classes.add('nav-project-details__title');
    _projectOrganizations = new DivElement()
      ..classes.add('nav-project-details__organization');
    var projectDetails = new DivElement()
      ..classes.add('nav-project-details')
      ..append(_projectTitle)
      ..append(_projectOrganizations);
    authHeaderViewPartial = new AuthHeaderViewPartial();

    navViewElement.append(_appLogos);
    navViewElement.append(_navLinks);
    navViewElement.append(projectDetails);
    navViewElement.append(authHeaderViewPartial.authElement);
  }

  void showParent(controller.NavAction navAction) {
    switch(navAction) {
      case controller.NavAction.none:
        _dashboardLink.classes.toggle('nav-links__link--show', false);
        _allProjectsLink.classes.toggle('nav-links__link--show', false);
        break;
      case controller.NavAction.allProjects:
        _allProjectsLink.classes.toggle('nav-links__link--show', true);
        _dashboardLink.classes.toggle('nav-links__link--show', false);
        break;
      case controller.NavAction.dashboard:
        _dashboardLink.classes.toggle('nav-links__link--show', true);
        _allProjectsLink.classes.toggle('nav-links__link--show', false);
        break;
    }
  }

  void set projectTitle(String projectName) => _projectTitle.text = projectName;

  void set projectOrganizations(List<String> organizations) => _projectOrganizations.text = organizations?.first;
}

class AuthHeaderViewPartial {
  DivElement authElement;
  DivElement _userPic;
  DivElement _userName;
  ButtonElement _signOutButton;
  ButtonElement _signInButton;

  AuthHeaderViewPartial() {
    authElement = new DivElement()
      ..classes.add('auth-header');

    _userPic = new DivElement()
      ..classes.add('auth-header__user-pic');
    authElement.append(_userPic);

    _userName = new DivElement()
      ..classes.add('auth-header__user-name');
    authElement.append(_userName);

    _signOutButton = new ButtonElement()
      ..text = 'Sign out'
      ..onClick.listen((_) => controller.command(controller.UIAction.signOutButtonClicked, null));
    authElement.append(_signOutButton);

    _signInButton = new ButtonElement()
      ..text = 'Sign in'
      ..onClick.listen((_) => controller.command(controller.UIAction.signInButtonClicked, null));
    authElement.append(_signInButton);
  }

  void signIn(String userName, userPicUrl) {
    // Set the user's profile pic and name
    _userPic.style.backgroundImage = 'url($userPicUrl)';
    _userName.text = userName;

    // Show user's profile pic, name and sign-out button.
    _userName.attributes.remove('hidden');
    _userPic.attributes.remove('hidden');
    _signOutButton.attributes.remove('hidden');

    // Hide sign-in button.
    _signInButton.setAttribute('hidden', 'true');
  }

  void signOut() {
    // Hide user's profile pic, name and sign-out button.
    _userName.attributes['hidden'] = 'true';
    _userPic.attributes['hidden'] = 'true';
    _signOutButton.attributes['hidden'] = 'true';

    // Show sign-in button.
    _signInButton.attributes.remove('hidden');
  }
}

abstract class BaseView {
  DivElement get renderElement;
}

class ContentView {
  DivElement contentViewElement;

  ContentView() {
    contentViewElement = new DivElement()..classes.add('content');
  }

  void renderView(BaseView view) {
    contentViewElement.children.clear();
    contentViewElement.append(view.renderElement);
  }
}

class AuthMainView extends BaseView {
  DivElement authElement;
  ButtonElement _signInButton;

  final descriptionText1 = 'Sign in to Katikati';
  final descriptionText2 = 'Please contact Africa\'s Voices for login details.';

  AuthMainView() {
    authElement = new DivElement()
      ..classes.add('auth-main');

    var logosContainer = new DivElement()
      ..classes.add('auth-main__logos');
    authElement.append(logosContainer);

    var avfLogo = new ImageElement(src: 'assets/africas-voices-logo.svg')
      ..classes.add('auth-main__partner-logo');
    logosContainer.append(avfLogo);

    var shortDescription = new DivElement()
      ..classes.add('auth-main__project-description')
      ..append(new ParagraphElement()..text = descriptionText1)
      ..append(new ParagraphElement()..text = descriptionText2);
    authElement.append(shortDescription);

    _signInButton = new ButtonElement()
      ..text = 'Sign in'
      ..onClick.listen((_) => controller.command(controller.UIAction.signInButtonClicked, null));
    authElement.append(_signInButton);
  }

  DivElement get renderElement => authElement;
}

class ProjectSelectorView extends BaseView {
  DivElement projectListViewElement;

  ProjectSelectorView (Map<String, List<String>> projectData, Map<String, String> teamMembers) {
    projectListViewElement = new DivElement()
      ..classes.add('project-list-view');
    projectListViewElement.append(
      new HeadingElement.h2()
        ..classes.add('list-view-title')
        ..text = 'Projects'
    );
    projectListViewElement.append(_createProjectList(projectData));
    projectListViewElement.append(
      new HeadingElement.h2()
        ..classes.add('list-view-title')
        ..text = 'Team members'
    );
    projectListViewElement.append(_createTeamList(teamMembers));
  }

  DivElement get renderElement => projectListViewElement;

  DivElement _createProjectList(Map<String, List<String>> projectData) {
    var projectList = new DivElement()
      ..classes.add('list-view');
    projectData.forEach((project, members) {
      var membersList = members.length <= 2 ?
        members.take(2).join(', ') : '${members.take(2).join(", ")} & ${members.length - 2} others';
      var projectListItem = new DivElement()
        ..classes.add('list-view-item')
        ..append(
          new SpanElement()
            ..classes.add('list-view-item__details')
            ..innerHtml = '$project&emsp;$membersList'
        )
        ..append(
          new SpanElement()
            ..classes.add('list-view-item__actions')
            ..append(
              new AnchorElement()
                ..classes.add('list-view-item__action-link')
                ..text = 'View'
                ..onClick.listen((_) =>
                    controller.command(controller.UIAction.viewProject, new controller.ProjectData(project, members)))
            )
            ..append(
              new AnchorElement()
                ..classes.add('list-view-item__action-link')
                ..text = 'Configure'
                ..onClick.listen((_) =>
                    controller.command(controller.UIAction.configureProject, new controller.ProjectData(project, members)))
            )
        );
      projectList.append(projectListItem);
    });
    projectList.append(
      new DivElement()
        ..classes.addAll(['list-view-item', 'list-view-item--dotted'])
        ..append(
          SpanElement()
            ..classes.add('add-item')
            ..append(
              new ParagraphElement()
                ..classes.add('add-item__icon')
                ..text = '+'
            )
            ..append(
              new ParagraphElement()
                ..classes.add('add-item__text')
                ..text = 'New Project'
            )
        )
        ..onClick.listen((_) => controller.command(controller.UIAction.addProject, null))
    );
    return projectList;
  }

  DivElement _createTeamList(Map<String, String> teamMembers) {
    var teamList = new DivElement()
      ..classes.add('list-view');
    teamMembers.forEach((name, email) {
      var teamListItem = new DivElement()
        ..classes.add('list-view-item')
        ..append(
          new SpanElement()
            ..classes.add('list-view-item__details')
            ..innerHtml = '$name&emsp;$email'
        );
      teamList.append(teamListItem);
    });
    teamList.append(
      new DivElement()
        ..classes.addAll(['list-view-item', 'list-view-item--dotted'])
        ..append(
          SpanElement()
            ..classes.add('add-item')
            ..append(
              new ParagraphElement()
                ..classes.add('add-item__icon')
                ..text = '+'
            )
            ..append(
              new ParagraphElement()
                ..classes.add('add-item__text')
                ..text = 'New team member'
            )
        )
        ..onClick.listen((_) => controller.command(controller.UIAction.addTeamMember, null))
    );
    return teamList;
  }
}

class DashboardView extends BaseView {
  List<ActivePackagesViewPartial> activePackages;
  List<AvailablePackagesViewPartial> availablepackages;

  DivElement dashboardViewElement;
  DivElement activePackagesContainer;
  DivElement availablePackagesContainer;

  DashboardView(Map conversationData) {
    activePackages = [];
    availablepackages = [];
    dashboardViewElement = new DivElement()
        ..classes.add('dashboard')
        ..append(
          new DivElement()
            ..classes.add('project-actions')
            ..append(
              new SpanElement()
                ..classes.add('project-actions__action')
                ..append(
                  new AnchorElement()
                    ..classes.add('project-actions__action-link')
                    ..text = "Configure project"
                    ..href = "#/project-configuration"
                )
                ..append(
                  new SpanElement()
                    ..classes.add('project-actions__action-icon')
                    ..text = '>'
                )
            )
            ..append(
              new SpanElement()
                ..classes.add('project-actions__action')
                ..append(
                  new AnchorElement()
                    ..classes.add('project-actions__action-link')
                    ..text = "Oversight dashboard"
                    ..href = "#"
                )
                ..append(
                  new SpanElement()
                    ..classes.add('project-actions__action-icon')
                    ..text = '>'
                )
            )
            ..append(
              new SpanElement()
                ..classes.add('project-actions__action')
                ..append(
                  new AnchorElement()
                    ..classes.add('project-actions__action-link')
                    ..text = "View conversations"
                    ..href = "#"
                )
                ..append(
                  new SpanElement()
                    ..classes.add('project-actions__action-icon')
                    ..text = '>'
                )
            )
        )
        ..append(
          new DivElement()
            ..classes.add('project-summary')
            ..append(
              new HeadingElement.h1()
                ..classes.add('group-title')
                ..text = 'Summary'
            )
            ..append(
              new ImageElement() //TODO To be replaced by real chart element
                ..classes.add('project-summary__chart')
                ..src = 'assets/sample-summary-chart.png'
            )
        );
        var projectAudienceContent = new DivElement()
          ..classes.add('project-audience-content');

          for (var conversations in conversationData['conversations']) {
            projectAudienceContent.append(
              new DivElement()
                ..classes.add('project-audience-content-item')
                ..append(
                  new ParagraphElement()
                    ..classes.add('project-audience-content-item__text')
                    ..text = '" ${conversations['text']}'
                )
                ..append(
                  new SpanElement()
                    ..classes.add('project-audience-content-item__description')
                    ..text = '- ${conversations['demogs']}'
                )
                ..append(
                  new AnchorElement()
                    ..classes.add('project-audience-content-item__action-link')
                    ..href  = '#'
                    ..text = 'View'
                )
            );
        }

        dashboardViewElement.append(
          new DivElement()
            ..classes.add('project-audience')
            ..append(
              new DivElement()
                ..classes.add('project-audience-header')
                ..append(
                  new HeadingElement.h1()
                    ..classes.add('group-title')
                    ..text = 'People'
                )
                ..append(
                  new DivElement()
                    ..classes.add('project-audience-actions')
                    ..append(
                      new DivElement()
                        ..classes.add('project-audience-action')
                        ..append(
                          new SpanElement()
                            ..classes.add('project-audience-action__text')
                            ..text = '${conversationData['needs-urgent-intervention']} people need urgent intervention'
                        )
                        ..append(
                          new SpanElement()
                            ..classes.add('project-audience-action__icon')
                            ..text = '>'
                        )
                    )
                    ..append(
                      new DivElement()
                        ..classes.add('project-audience-action')
                        ..append(
                          new SpanElement()
                            ..classes.add('project-audience-action__text')
                            ..text = '${conversationData['awaiting-reply']} people awaiting your reply'
                        )
                        ..append(
                          new SpanElement()
                            ..classes.add('project-audience-action__icon')
                            ..text = '>'
                        )
                    )
                )
            )
            ..append(projectAudienceContent)
        );
    activePackagesContainer = new DivElement()
      ..classes.add('package-group');
    availablePackagesContainer = new DivElement()
      ..classes.add('package-group');
    dashboardViewElement.append(activePackagesContainer);
    dashboardViewElement.append(availablePackagesContainer);
  }

  DivElement get renderElement => dashboardViewElement;

  void renderActivePackages() {
    activePackagesContainer.children.clear();
    activePackagesContainer.append(
      new HeadingElement.h1()
        ..classes.add('group-title')
        ..text = "Active packages"
    );
    if (activePackages.isNotEmpty) {
      activePackages.forEach((package) => activePackagesContainer.append(package.packageElement));
    }
  }

  void renderAvailablePackages() {
    availablePackagesContainer.children.clear();
    availablePackagesContainer.append(
      new HeadingElement.h1()
        ..classes.add('group-title')
        ..text = "Add a package"
    );
    if (activePackages.isNotEmpty) {
      availablepackages.forEach((package) => availablePackagesContainer.append(package.packageElement));
    }
  }
}

class ActivePackagesViewPartial {
  DivElement packageElement;

  ActivePackagesViewPartial(String packageId, String packageName, String conversationsLink, String configurationLink, String chartData) {
    packageElement = new DivElement()
      ..classes.add('package');
    var packageNameElement = new ParagraphElement();
    packageNameElement
      ..classes.add('active-package-title__text')
      ..text = packageName
      ..onBlur.listen((event) {
        packageNameElement.contentEditable = 'false';
        controller.command(controller.UIAction.editActivePackage, new controller.PackageConfigurationData(packageId, packageName, (event.target as Element).text));
      });
    var packageNameContainer = new SpanElement()
      ..classes.add('active-package-title')
      ..append(packageNameElement);
    var packageActionsContainer = new DivElement()
      ..classes.add('active-package-actions')
      ..append(
        new AnchorElement()
          ..classes.add('active-package-actions__action-link')
          ..text = 'Dashboard'
          ..href = '#/dashboard'
      )
      ..append(
        new AnchorElement()
          ..classes.add('active-package-actions__action-link')
          ..text = 'Conversations'
          ..href = conversationsLink
      )
      ..append(
        new AnchorElement()
          ..classes.add('active-package-actions__action-link')
          ..text = 'Configure'
          ..href = configurationLink
      );
    var packageMainContainer = new DivElement()
      ..classes.add('active-package-main-container')
      ..append(packageNameContainer)
      ..append(packageActionsContainer);
    var packageChart = new DivElement()
      ..classes.add('active-package-chart')
      ..append(
        new ImageElement() //TODO To be replaced by real chart element
          ..classes.add('active-package-chart__data')
          ..src = 'assets/sample-package-chart.png'
      )
      ..append(
        new ParagraphElement()
          ..classes.add('active-package-chart__description')
          ..text = chartData
      );
    packageElement
      ..append(packageMainContainer)
      ..append(packageChart)
      ..append(
        new AddActionElement(
          packageElement,
          '',
          ['Rename', 'Duplicate'],
          (MouseEvent event) {
            var menuItem = (event.target as Element).dataset['item'];
            switch(menuItem) {
              case 'Rename':
                packageNameElement.contentEditable = 'true';
                packageNameElement.focus();
                _cursorToEnd(packageNameElement);
                break;
              case 'Duplicate':
                controller.command(controller.UIAction.duplicatePackage, controller.PackageConfigurationData(packageId, packageName));
                break;
            }
          },
          ['active-package-menu'],
          {},
          ['add-tag-dropdown', 'active-package-dropdown']
        ).renderElement
      );
  }
}

class AvailablePackagesViewPartial {
  DivElement packageElement;

  AvailablePackagesViewPartial(String packageName, String descriptionTitle, Map<String, String> descriptionDetails) {
    packageElement = new DivElement()
      ..classes.addAll(['package', 'package--dotted'])
      ..append(
        new SpanElement()
          ..classes.add('available-package-name')
          ..text = packageName
      )
      ..append(
        new DivElement()
          ..classes.add('available-package-action')
          ..append(
            new SpanElement()
              ..classes.add('available-package-action__icon')
              ..text = '+'
          )
          ..append(
            new AnchorElement()
              ..classes.add('available-package-action__link')
              ..text = 'Add $packageName package'
              ..href = '#/dashboard'
          )
          ..onClick.listen((event) => controller.command(controller.UIAction.addPackage, new controller.PackageConfigurationData('', packageName)))
      )
      ..append(
        new SpanElement()
          ..classes.add('available-package-description-title')
          ..text = descriptionTitle
      );
    descriptionDetails.forEach((title, description) {
      packageElement
        ..append(
          new DivElement()
            ..classes.add('available-package-description-details')
            ..append(
              new HeadingElement.h5()
                ..classes.add('available-package-description-details__title')
                ..text = title.toUpperCase()
            )
            ..append(
              new ParagraphElement()
                ..classes.add('available-package-description-details__description')
                ..text = description
            )
        );
    });
  }
}

class PackageConfiguratorView extends BaseView {
  DivElement packageConfiguratorViewElement;
  DivElement _packageConfiguratorSidebar;
  DivElement _packageConfiguratorContent;
  Map<String, String> activePackages;
  model.Configuration configurationData;

  PackageConfiguratorView(this.activePackages, this.configurationData) {
    packageConfiguratorViewElement = new DivElement()
      ..classes.add('configure-package-view');
    _packageConfiguratorSidebar = new DivElement()
      ..classes.add('configure-package-sidebar');
    _packageConfiguratorContent = new DivElement()
      ..classes.add('configure-package-content');
    _buildSidebarPartial();
    _buildContentPartial();
    packageConfiguratorViewElement.append(_packageConfiguratorSidebar);
    packageConfiguratorViewElement.append(_packageConfiguratorContent);
  }

  DivElement get renderElement => packageConfiguratorViewElement;

  void _buildSidebarPartial() {
    _packageConfiguratorSidebar.append(
      new SpanElement()
        ..text = 'Active Packages'
        ..classes.add('configure-package-sidebar__title')
    );

    var packageList = new Element.ul()
      ..classes.add('selected-active-package-list');

    activePackages.forEach((packageId, packageName) {
      var packageListItem = new DivElement();
      var packageListItemText = new Element.li();
      packageListItemText
        ..classes.add('selected-active-package-list__item-text')
        ..text = packageName
        ..onClick.listen((event) { if (event.target == document.activeElement) event.stopPropagation(); })
        ..onBlur.listen((event) {
          packageListItemText.contentEditable = 'false';
          controller.command(controller.UIAction.editActivePackage, controller.PackageConfigurationData(packageId, packageName, (event.target as Element).text));
        });
      packageListItem
        ..dataset['id'] = packageId
        ..classes.add('selected-active-package-list__item')
        ..classes.toggle('selected-active-package-list__item--selected', (packageId == controller.selectedPackage))
        ..append(packageListItemText)
        ..append(
          new AddActionElement(
            packageListItem,
            '',
            ['Rename', 'Duplicate'],
            (MouseEvent event) {
              var menuItem = (event.target as Element).dataset['item'];
              switch(menuItem) {
                case 'Rename':
                  packageListItemText.contentEditable = 'true';
                  packageListItemText.focus();
                  _cursorToEnd(packageListItemText);
                  break;
                case 'Duplicate':
                  controller.command(controller.UIAction.duplicatePackage, controller.PackageConfigurationData(packageId, packageName));
                  break;
              }
            },
            ['selected-active-package-list__item-action'],
            {'selected-active-package-list__item-action--show': (packageId == controller.selectedPackage)},
            ['add-tag-dropdown', 'selected-package-dropdown']
          ).renderElement
        )
        ..onClick.listen((event) {
          if (!(event.target == packageListItem)) return;
          controller.command(controller.UIAction.loadPackageConfigurationView, new controller.PackageConfigurationData(packageId, packageName));
        });
      packageList.append(packageListItem);
    });

    _packageConfiguratorSidebar.append(packageList);
  }

  void _buildContentPartial() {
    List<TagView> hasAllTags = [];
    configurationData.hasAllTags.forEach((tag, tagType) {
      hasAllTags.add(new TagView(tag, tagType, controller.hasAllTagsChanged));
    });
    var hasAllTagsContainer = new TagListView(hasAllTags, configurationData.availableTags, controller.hasAllTagsChanged).renderElement;

    List<TagView> containsLastInTurnTags = [];
    configurationData.containsLastInTurnTags.forEach((tag, tagType) {
      containsLastInTurnTags.add(new TagView(tag, tagType, controller.containsLastInTurnTagsChanged));
    });
    var containsLastInTurnTagsContainer = new TagListView(containsLastInTurnTags, configurationData.availableTags, controller.containsLastInTurnTagsChanged).renderElement;

    List<TagView> hasNoneTags = [];
    configurationData.hasNoneTags.forEach((tag, tagType) {
      hasNoneTags.add(new TagView(tag, tagType, controller.hasNoneTagsChanged));
    });
    var hasNoneTagsContainer = new TagListView(hasNoneTags, configurationData.availableTags, controller.hasNoneTagsChanged).renderElement;

    _packageConfiguratorContent.append(
      new DivElement()
        ..classes.add('configure-package-tags')
        ..append(
          new DivElement()
            ..classes.add('conversation-tags')
            ..append(
              new DivElement()
                ..classes.add('conversation-tags__row')
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-tags__title')
                    ..text = 'Who do you want to talk to'
                )
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-tags__sub-title')
                    ..text = 'Conversations has tags'
                )
                ..append(hasAllTagsContainer)
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-tags__text--center')
                    ..text = 'and'
                )
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-tags__sub-title')
                    ..text = 'Last in turn contains ...'
                )
                ..append(containsLastInTurnTagsContainer)
            )
            ..append(
              new DivElement()
                ..classes.add('conversation-tags__row')
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-tags__title')
                    ..text = 'Who do you NOT want to talk to?'
                )
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-tags__sub-title')
                    ..text = 'Conversation has tags'
                )
                ..append(hasNoneTagsContainer)
            )
        )
        ..append(
          new DivElement()
            ..classes.add('conversation-charts')
            ..append(
              new DivElement()
                ..classes.add('configure-package-charts')
                ..append(
                   new ImageElement()
                    ..classes.add('configure-package-charts__chart')
                    ..src = 'assets/sample-chart.png'
                )
            )
            ..append(
              new DivElement()
                ..classes.add('configure-package-actions')
                ..append(
                  new AnchorElement()
                    ..classes.add('configure-package-actions__action')
                    ..href = '#'
                    ..text = 'Go to Conversations'
                )
                ..append(
                  new AnchorElement()
                    ..classes.add('configure-package-actions__action')
                    ..href = '#'
                    ..text = 'Explore'
                )
            )
        )
    );

    var suggestedRepliesContainer =
      new ResponseListView(configurationData.suggestedReplies, controller.addNewResponse, controller.updateResponse, controller.reviewResponse, controller.removeResponse).renderElement;

    _packageConfiguratorContent.append(
      new DivElement()
        ..classes.add('configure-package-responses')
        ..append(
          new DivElement()
            ..classes.add('configure-package-responses-headers')
            ..append(
              new ParagraphElement()
                ..text = 'What do you want to say?'
            )
            ..append(
              new ParagraphElement()
                ..text = '3rd Party reviews'
            )
        )
        ..append(suggestedRepliesContainer)
    );

    List<TagView> addsTags = [];
    configurationData.addsTags.forEach((tag, tagType) {
      addsTags.add(new TagView(tag, tagType, controller.addsTagsChanged, true));
    });
    var addsTagsContainer = new TagListView(addsTags, configurationData.availableTags, controller.addsTagsChanged, true).renderElement;

    _packageConfiguratorContent
    ..append(
      new DivElement()
        ..classes.add('configure-package-labels')
        ..append(
          new ParagraphElement()
            ..classes.add('conversation-tags__title')
            ..text = 'What new labels would like to tag the message with?'
        )
        ..append(addsTagsContainer)
    )
    ..append(
      new DivElement()
        ..classes.add('configure-package-actions')
        ..append(
          new ButtonElement()
            ..classes.add('save-configuration-btn')
            ..text = 'Save Configuration'
            ..onClick.listen((_) => controller.command(controller.UIAction.savePackageConfiguration, null))
        )
    );
  }
}

class TagListView extends BaseView {
  List<TagView> tagElements;
  DivElement _tagsContainer;
  SpanElement _tagsActionContainer;
  Function onTagChangedCallback;

  TagListView(this.tagElements, Map<String, model.TagType> availableTags, this.onTagChangedCallback, [bool tagsEditable = false]) {
    _tagsContainer = new DivElement()
      ..classes.add('tags');
    _tagsActionContainer = new SpanElement()
      ..classes.add('tags__actions');
    Function addAction;
    if (tagsEditable) {
      addAction = onTagChangedCallback;
    } else {
      addAction = (MouseEvent event) {
        var tag = (event.target as Element).dataset['item'];
        if (tag == '--None--') return;
        onTagChangedCallback(tag, availableTags[tag], controller.TagOperation.add);
      };
    }
    _tagsActionContainer.append(
      new AddActionElement(_tagsActionContainer, '+', availableTags.keys.toList(), addAction, ['button-add-tag'], {}, ['add-tag-dropdown'], tagsEditable).renderElement
    );
    _tagsContainer.append(_tagsActionContainer);
    tagElements.forEach((tag) {
      _tagsActionContainer.insertAdjacentElement('beforebegin', tag.renderElement);
    });
  }

  DivElement get renderElement => _tagsContainer;
}

class TagView extends BaseView {
  DivElement _tagElement;
  SpanElement _tagText;
  Function onTagChangedCallback;

  TagView(String tag, model.TagType tagType, this.onTagChangedCallback, [bool isEditableTag = false]) {
    _tagElement = _createTag(tag, tagType, isEditableTag);
  }

  DivElement get renderElement => _tagElement;

  DivElement _createTag(String tag, model.TagType tagType, bool isEditableTag) {
    var tagElement = new DivElement()
      ..classes.add('tag')
      ..dataset['id'] = tag.isEmpty ? 'id-123' : tag;

    switch (tagType) {
      case model.TagType.Important:
        tagElement.classes.add('tag--important');
        break;
      default:
        break;
    }

    _tagText = new SpanElement()
      ..classes.add('tag__name')
      ..text = tag
      ..title = tag;

    tagElement
      ..append(_tagText)
      ..append(
        new SpanElement()
          ..classes.add('tag__remove-btn')
          ..text = 'x'
          ..onClick.listen((_) {
            if (isEditableTag) {
              onTagChangedCallback(tag, tag, tagType, controller.TagOperation.remove);
              return;
            }
            onTagChangedCallback(tag, tagType, controller.TagOperation.remove);
          })
      );

    if (isEditableTag) {
      _tagText.contentEditable = 'true';
      _tagText.onBlur.listen((event) => onTagChangedCallback(tag, (event.target as Element).text, tagType, controller.TagOperation.update));
    }

    return tagElement;
  }

  void focus() {
    _tagText.focus(); // HACK: this is looking a bit odd - if the user moves the cursor at the end of the text box
                      // then the cursor jumps over the x. Needs investigating and fixing.
  }
}

class ResponseView {
  Element _responseElement;
  Function onUpdateResponseCallback;

  ResponseView(int rowIndex, int colIndex, String response, int responseCount, this.onUpdateResponseCallback) {
    var responseCounter = new SpanElement()
      ..classes.add('conversation-response-language__text-count')
      ..classes.toggle('conversation-response-language__text-count--alert', responseCount > 160)
      ..text = '${responseCount}/160';
    var responseText =  new ParagraphElement();
    responseText
      ..classes.add('conversation-response-language__text')
      ..classes.toggle('conversation-response-language__text--alert', responseCount > 160)
      ..text = response != null ? response : ''
      ..contentEditable = 'true'
      ..dataset['index'] = '$colIndex'
      ..onBlur.listen((event) => onUpdateResponseCallback(rowIndex, colIndex, (event.target as Element).text))
      ..onInput.listen((event) {
        int count = responseText.text.split('').length;
        responseCounter.text = '${count}/160';
        responseText.classes.toggle('conversation-response-language__text--alert', count > 160);
        responseCounter.classes.toggle('conversation-response-language__text-count--alert', count > 160);
      });
    _responseElement = new DivElement()
      ..classes.add('conversation-response-language')
      ..append(responseText)
      ..append(responseCounter);
  }
    Element get renderElement => _responseElement;
}

class ResponseListView extends BaseView {
  DivElement _responsesContainer;
  Function onAddNewResponseCallback;
  Function onUpdateResponseCallback;
  Function onReviewResponseCallback;
  Function onRemoveResponseCallback;

  ResponseListView(List<Map> suggestedReplies, this.onAddNewResponseCallback, this.onUpdateResponseCallback, this.onReviewResponseCallback, this.onRemoveResponseCallback) {
    _responsesContainer = new DivElement()
      ..classes.add('conversation-responses');
    for (int i = 0; i < suggestedReplies.length; i++) {
      _responsesContainer.append(_createResponseEntry(i, suggestedReplies[i]));
    }
    _responsesContainer.append(
      new ButtonElement()
        ..classes.add('button-add-conversation-responses')
        ..text = '+'
        ..onClick.listen((event) => onAddNewResponseCallback())
    );
  }

  DivElement get renderElement => _responsesContainer;

  DivElement _createResponseEntry(int rowIndex, [Map response]) {
    var responseEntry = new DivElement()
      ..classes.add('conversation-response')
      ..dataset['index'] = '$rowIndex';
    responseEntry.append(
        new ButtonElement()
          ..classes.add('button-remove-conversation-responses')
          ..text = 'x'
          ..onClick.listen((_) {
            var removeResponsesModal = new DivElement()
              ..classes.add('remove-conversation-responses-modal');
            removeResponsesModal
              ..append(
                new ParagraphElement()
                  ..classes.add('remove-conversation-responses-modal__message')
                  ..text = 'Are you sure?'
              )
              ..append(
                new DivElement()
                  ..classes.add('remove-conversation-responses-modal-actions')
                  ..append(
                    new ButtonElement()
                      ..classes.add('remove-conversation-responses-modal-actions__action')
                      ..text = 'Yes'
                      ..onClick.listen((_) => onRemoveResponseCallback(rowIndex))
                  )
                  ..append(
                    new ButtonElement()
                      ..classes.add('remove-conversation-responses-modal-actions__action')
                      ..text = 'No'
                      ..onClick.listen((_) => removeResponsesModal.remove())
                  )
              );
            responseEntry.append(removeResponsesModal);
          })
      );
    for (int i = 0; i < response['messages'].length; i++) {
      int responseCount = response['messages'][i] == null ? 0 : response['messages'][i].split('').length;
      responseEntry.append(new ResponseView(rowIndex, i, response['messages'][i], responseCount, onUpdateResponseCallback).renderElement);
    }
    responseEntry.append(
      DivElement()
        ..classes.add('conversation-response__reviewed')
        ..append(
          new CheckboxInputElement()
              ..classes.add('conversation-response__reviewed-state')
              ..checked = response != null ? response['reviewed'] : false
              ..onClick.listen((event) => onReviewResponseCallback(rowIndex, (event.target as CheckboxInputElement).checked))
        )
        ..append(
          new ParagraphElement()
            ..classes.add('conversation-response__reviewed-description')
            ..text = response != null ? '${response['reviewed-by']}, ${response['reviewed-date']}' : ''
        )
    );
    return responseEntry;
  }
}

class ProjectConfigurationView extends BaseView{
  DivElement _configurationViewElement;
  FormElement _projectConfigurationForm;
  Map _formData;
  List<String> additionalProjectLanguages;

  ProjectConfigurationView(Map formData, this.additionalProjectLanguages) {
    _formData = json.decode(json.encode(formData));
    _configurationViewElement = new DivElement()
      ..classes.add('project-configuration');
    _projectConfigurationForm = new FormElement()
      ..classes.add('configuration-form');
    _buildForm();
    _configurationViewElement.append(_projectConfigurationForm);
  }

  DivElement get renderElement => _configurationViewElement;

  void _buildForm() {
    _projectConfigurationForm.children.clear();
    var projectLanguages = new DivElement()
      ..classes.add('form-group')
      ..append(
        new LabelElement()
          ..classes.add('form-group__label')
          ..text = 'Project Languages'
      );
    _formData['project-languages'].forEach((language, data) {
      projectLanguages
        ..append(
          new DivElement()
            ..classes.addAll(['form-group-item', 'form-group-item--col4'])
            ..append(
              new ButtonElement()
                ..classes.add('form-group-item-action-remove')
                ..text = 'X'
                ..onClick.listen((event) {
                  var action = (event.target as Element);
                  additionalProjectLanguages.add(action.nextElementSibling.text);
                  action.parent.remove();
                 })
            )
            ..append(
              new LabelElement()
                ..classes.add('form-group-item__label')
                ..text = language
            )
            ..append(
              new DivElement()
                ..classes.addAll(['form-group-item', 'form-group-item--shrink'])
                ..append(
                  new CheckboxInputElement()
                    ..classes.add('form-group-item__value')
                    ..checked = data['send']['value']
                    ..onChange.listen((event) {
                      _formData['project-languages'][language]['send']['value'] = (event.target as CheckboxInputElement).checked;
                    })
                )
                ..append(
                  new LabelElement()
                    ..classes.add('form-group-item__label')
                    ..text = data['send']['label']
                )
            )
            ..append(
              new DivElement()
                ..classes.addAll(['form-group-item', 'form-group-item--shrink'])
                ..append(
                  new CheckboxInputElement()
                    ..classes.add('form-group-item__value')
                    ..checked = data['receive']['value']
                    ..onChange.listen((event) {
                      _formData['project-languages'][language]['receive']['value'] = (event.target as CheckboxInputElement).checked;
                    })
                )
                ..append(
                  new LabelElement()
                    ..classes.add('form-group-item__label')
                    ..text = data['receive']['label']
                )
            )
        );
    });
    var addConfigurationLanguage = new DivElement()
      ..classes.add('form-group-item-action-add');
    addConfigurationLanguage
      ..append(
        new SpanElement()
          ..classes.add('form-group-item-action-add__icon')
          ..text = '+'
      )
      ..append(
        new LabelElement()
          ..classes.add('form-group-item-action-add__label')
          ..text = 'Add new language'
      )
      ..onClick.listen((event) {
        event.stopPropagation();
        var additionalLanguageDropdown = new Element.ul()
          ..classes.add('add-language-dropdown');
        var languagesToAdd = additionalProjectLanguages.isEmpty ? ['--None--'] : additionalProjectLanguages;
        for (var language in languagesToAdd) {
          additionalLanguageDropdown.append(
            new Element.li()
              ..classes.add('add-language-dropdown__item')
              ..text = language
              ..onClick.listen((event) {
                if (language == '--None--') return;
                _formData['project-languages'][language] = {
                  'send': {'label': 'can send', 'value': false},
                  'receive': {'label': 'can receive', 'value': false}
                };
                additionalProjectLanguages.removeWhere((l) => l == language);
                _buildForm();
              })
          );
        }
        var documentOnClickSubscription;
          documentOnClickSubscription = document.onClick.listen((event) {
            event.stopPropagation();
            additionalLanguageDropdown.remove();
          documentOnClickSubscription.cancel();
        });
        addConfigurationLanguage.append(additionalLanguageDropdown);
      });
    projectLanguages.append(addConfigurationLanguage);
    _projectConfigurationForm
      ..append(projectLanguages)
      ..append(
        new DivElement()
          ..classes.add('form-group')
          ..append(
            new DivElement()
              ..classes.addAll(['form-group-item', 'form-group-item--shrink'])
              ..append(
                new CheckboxInputElement()
                  ..classes.add('form-group-item__value')
                  ..checked = _formData['automated-translations']['value']
                  ..onChange.listen((event) {
                      _formData['automated-translations']['value'] = (event.target as CheckboxInputElement).checked;
                  })
              )
              ..append(
                new LabelElement()
                  ..classes.add('form-group-item__label')
                  ..text = _formData['automated-translations']['label']
              )
          )
      );
    var userConfiguration = new DivElement()
      ..classes.add('form-group')
      ..append(
        new LabelElement()
          ..classes.add('form-group__label')
          ..text = 'User configuration'
      );
      _formData['user-configuration'].forEach((type, config) {
        userConfiguration
          ..append(
            new DivElement()
              ..classes.add('form-group-item')
              ..append(
                new LabelElement()
                  ..classes.add('form-group-item__label')
                  ..text = config['label']
              )
              ..append(
                new InputElement()
                  ..classes.addAll(['form-group-item__value', 'form-group-item__value--text'])
                  ..type = 'text'
                  ..value = config['value']
                  ..onBlur.listen((event) {
                    _formData['user-configuration'][type]['value'] = (event.target as InputElement).value;
                  })
              )
          );
      });
    _projectConfigurationForm..append(userConfiguration);
    var codaIntegration = new DivElement()
      ..classes.add('form-group')
      ..append(
        new LabelElement()
          ..classes.add('form-group__label')
          ..text = 'Coda integration'
      );
    _formData['coda-integration'].forEach((type, config) {
        codaIntegration
          ..append(
            new DivElement()
              ..classes.add('form-group-item')
              ..append(
                new LabelElement()
                  ..classes.add('form-group-item__label')
                  ..text = config['label']
              )
              ..append(
                new InputElement()
                  ..classes.addAll(['form-group-item__value', 'form-group-item__value--text'])
                  ..type = 'text'
                  ..value = config['value']
                  ..onBlur.listen((event) {
                    _formData['coda-integration'][type]['value'] = (event.target as InputElement).value;
                  })
              )
          );
      });
    _projectConfigurationForm..append(codaIntegration);
    var rapidproIntegration = new DivElement()
    ..classes.add('form-group')
    ..append(
      new LabelElement()
        ..classes.add('form-group__label')
        ..text = 'RapidPro integration'
    );
    rapidproIntegration
      ..append(
        new DivElement()
          ..classes.add('form-group-item')
          ..append(
            new LabelElement()
              ..classes.add('form-group-item__label')
              ..text = _formData['rapidpro-integration']['start-timestamp']['label']
          )
          ..append(
            new InputElement()
              ..classes.addAll(['form-group-item__value', 'form-group-item__value--text'])
              ..type = 'date'
              ..valueAsDate = DateTime.parse(_formData['rapidpro-integration']['start-timestamp']['value'])
              ..onChange.listen((event) {
                _formData['rapidpro-integration']['start-timestamp']['value'] = (event.target as InputElement).value;
              })
          )
      )
      ..append(
        new DivElement()
          ..classes.add('form-group-item')
          ..append(
            new LabelElement()
              ..classes.add('form-group-item__label')
              ..text = _formData['rapidpro-integration']['workspace-token']['label']
          )
          ..append(
            new InputElement()
              ..classes.addAll(['form-group-item__value', 'form-group-item__value--text'])
              ..type = 'text'
              ..value = _formData['rapidpro-integration']['workspace-token']['value']
              ..onBlur.listen((event) {
                _formData['rapidpro-integration']['workspace-token']['value'] = (event.target as InputElement).value;
              })
          )
      );
    _projectConfigurationForm
      ..append(rapidproIntegration)
      ..append(
        new ButtonElement()
          ..classes.add('save-configuration-btn')
          ..text = 'Save changes'
          ..onClick.listen((event) {
            event.preventDefault();
            controller.command(controller.UIAction.saveProjectConfiguration, new controller.ProjectConfigurationData(_formData));
          })
      );
  }
}

class AddActionElement {
  ButtonElement _addAction;
  Element container;
  String addActionLabel;
  List<String> dropdownItems;
  List<String> actionClasses;
  Map<String, bool> toggleActionClasses;
  List<String> dropdownClasses;
  Function onAddAction;
  bool isEditableTag;


  AddActionElement(this.container, this.addActionLabel, this.dropdownItems, this.onAddAction, this.actionClasses, this.toggleActionClasses, this.dropdownClasses, [this.isEditableTag = false]) {
    _addAction = new ButtonElement()
      ..classes.addAll(actionClasses)
      ..text = addActionLabel
      ..onClick.listen((_) {
        if (isEditableTag) {
          _createEditableTag();
        } else {
          _createDropdown();
        }
    });

    if (toggleActionClasses != null) {
      toggleActionClasses.keys.toList().forEach((clazz) => _addAction.classes.toggle(clazz, toggleActionClasses[clazz]));
    }
  }

  void _createDropdown() {
    var dropdown = new Element.ul()
      ..classes.addAll(dropdownClasses);
    var items = dropdownItems.isEmpty ? ['--None--'] : dropdownItems;
    for (var item in items) {
      dropdown.append(
        new Element.li()
          ..classes.add('add-tag-dropdown__item')
          ..text = item
          ..dataset['item'] = item
          ..onClick.listen(onAddAction)
      );
    }
    container.append(dropdown);
    var documentOnClickSubscription;
    documentOnClickSubscription = document.onClick.listen((event) {
      if (event.target == document.activeElement) return;
      event.stopPropagation();
      dropdown.remove();
     documentOnClickSubscription.cancel();
    });
  }

  void _createEditableTag() {
    var tagElement = new TagView('', model.TagType.Normal, onAddAction, isEditableTag);
      container.insertAdjacentElement('beforebegin', tagElement.renderElement);
      tagElement.focus();
  }

  Element get renderElement => _addAction;
}

// Helpers

_cursorToEnd(Element element) {
  var range = document.createRange();
  range.selectNodeContents(element);
  range.collapse(false);
  var selection = window.getSelection();
  selection.removeAllRanges();
  selection.addRange(range);
}
