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
  DivElement _projectTitle;
  DivElement _projectOrganizations;
  AuthHeaderViewPartial authHeaderViewPartial;


  NavView() {
    navViewElement = new DivElement()
      ..classes.add('nav');
    _appLogos = new DivElement()
      ..classes.add('nav__app-logo')
      ..append(new ImageElement(src: 'assets/africas-voices-logo.svg'));
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
    navViewElement.append(projectDetails);
    navViewElement.append(authHeaderViewPartial.authElement);
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

  ActivePackagesViewPartial(String packageName, String conversationsLink, String configurationLink, String chartData) {
    packageElement = new DivElement()
      ..classes.add('package');
    var packageNameElement = new SpanElement()
      ..classes.add('active-package-title')
      ..append(
        new ParagraphElement()
          ..classes.add('active-package-title__text')
          ..text = packageName
      )
      ..append(
        new ImageElement()
          ..classes.add('active-package-title__icon')
          ..src='assets/info-icon.svg' //https://commons.wikimedia.org/wiki/File:Infobox_info_icon.svg
      );
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
      ..append(packageNameElement)
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
    packageElement.append(packageMainContainer);
    packageElement.append(packageChart);
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
              ..href = '#'
          )
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

class EscalatesConfigurationView extends PackageConfiguratorView {}

class PackageConfiguratorView extends BaseView {
  DivElement packageConfiguratorViewElement;
  DivElement _packageConfiguratorSidebar;
  DivElement _packageConfiguratorContent;

  PackageConfiguratorView() {
    packageConfiguratorViewElement = new DivElement()
      ..classes.add('configure-package-view');
    _packageConfiguratorSidebar = new DivElement()
      ..classes.add('configure-package-sidebar');
    _packageConfiguratorContent = new DivElement()
      ..classes.add('configure-package-content');
    _buildSidebarPartial();
    packageConfiguratorViewElement.append(_packageConfiguratorSidebar);
    packageConfiguratorViewElement.append(_packageConfiguratorContent);
  }

  DivElement get renderElement => packageConfiguratorViewElement;

  void _buildSidebarPartial() {
    Map<String, bool> activePackages = {'Escalates': true, 'Change Communications': false};

    _packageConfiguratorSidebar.append(
      new SpanElement()
        ..text = 'Active Packages'
        ..classes.add('configure-package-sidebar__title')
    );

    var packageList = new Element.ul()
      ..classes.add('selected-active-package-list');

    activePackages.forEach((packageName, selected) {
      packageList.append(
        new DivElement()
          ..classes.add('selected-active-package-list__item')
          ..append(
            new CheckboxInputElement()
              ..classes.add('selected-active-package-list__item-state')
              ..checked = selected
          )
          ..append(
            new Element.li()
              ..classes.add('selected-active-package-list__item-text')
              ..text = packageName
          )
      );
    });

    _packageConfiguratorSidebar.append(packageList);
  }
}

class BatchRepliesConfigurationView extends PackageConfiguratorView {
  DivElement hasAllTagsContainer;
  DivElement containsLastInTurnTagsContainer;
  DivElement hasNoneTagsContainer;
  DivElement suggestedRepliesContainer;
  DivElement addsTagsContainer;
  BatchRepliesConfigurationView(model.Configuration data) : super() {
    _buildContentPartial(data);
  }

  void _buildContentPartial(model.Configuration data) {
    List<TagView> hasAllTags = [];
    data.hasAllTags.forEach((tag, tagStyle) {
      hasAllTags.add(new TagView(tag, tagStyle, controller.hasAllTagsChanged));
    });
    hasAllTagsContainer = new TagListView(hasAllTags, data.availableTags, controller.hasAllTagsChanged).renderElement;

    List<TagView> containsLastInTurnTags = [];
    data.containsLastInTurnTags.forEach((tag, tagStyle) {
      containsLastInTurnTags.add(new TagView(tag, tagStyle, controller.containsLastInTurnTagsChanged));
    });
    containsLastInTurnTagsContainer = new TagListView(containsLastInTurnTags, data.availableTags, controller.containsLastInTurnTagsChanged).renderElement;

    List<TagView> hasNoneTags = [];
    data.hasNoneTags.forEach((tag, tagStyle) {
      hasNoneTags.add(new TagView(tag, tagStyle, controller.hasNoneTagsChanged));
    });
    hasNoneTagsContainer = new TagListView(hasNoneTags, data.availableTags, controller.hasNoneTagsChanged).renderElement;

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

    suggestedRepliesContainer =
      new ResponseListView(data.suggestedReplies, controller.addNewResponse, controller.updateResponse, controller.reviewResponse, controller.removeResponse).renderElement;

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
    data.addsTags.forEach((tag, tagStyle) {
      addsTags.add(new TagView(tag, tagStyle, controller.addsTagsChanged, true));
    });
    addsTagsContainer = new TagListView(addsTags, data.availableTags, controller.addsTagsChanged, true).renderElement;

    _packageConfiguratorContent.append(
      new DivElement()
        ..classes.add('configure-package-labels')
        ..append(
          new ParagraphElement()
            ..classes.add('conversation-tags__title')
            ..text = 'What new labels would like to tag the message with?'
        )
        ..append(addsTagsContainer)
    );
  }
}

class TagListView extends BaseView {
  List<TagView> tagElements;
  DivElement _tagsContainer;
  SpanElement _tagsActionContainer;
  Function onTagChangedCallback;

  TagListView(this.tagElements, Map<String, model.TagStyle> availableTags, this.onTagChangedCallback, [bool tagsEditable = false]) {
    _tagsContainer = new DivElement()
      ..classes.add('tags');
    _tagsActionContainer = new SpanElement()
      ..classes.add('tags__actions')
      ..append(
        new ButtonElement()
          ..classes.add('button-add-tag')
          ..text = '+'
          ..onClick.listen((event) {
            event.stopPropagation();
            if (tagsEditable) {
              var tagElement = new TagView('', model.TagStyle.Normal, onTagChangedCallback, tagsEditable);
              _tagsActionContainer.insertAdjacentElement('beforebegin', tagElement.renderElement);
              tagElement.focus();
              return;
            }
            _addTagDropdown(availableTags, onTagChangedCallback);
          })
      );
    _tagsContainer.append(_tagsActionContainer);
    tagElements.forEach((tag) {
      _tagsActionContainer.insertAdjacentElement('beforebegin', tag.renderElement);
    });
  }

  DivElement get renderElement => _tagsContainer;

  void _addTagDropdown(Map<String, model.TagStyle> tags, Function onTagChangedCallback) {
    var tagListDropdown = new Element.ul()
      ..classes.add('add-tag-dropdown');
    var tagsToShow = tags.isEmpty ? ['--None--'] : tags.keys;
    for (var tag in tagsToShow) {
      tagListDropdown.append(
        new Element.li()
          ..classes.add('add-tag-dropdown__item')
          ..text = tag
          ..onClick.listen((event) {
            if (tag == '--None--') return;
            onTagChangedCallback(tag, tags[tag], controller.TagOperation.ADD);
          })
      );
    }
    _tagsActionContainer.append(tagListDropdown);
    var documentOnClickSubscription;
    documentOnClickSubscription = document.onClick.listen((event) {
      event.stopPropagation();
      tagListDropdown.remove();
     documentOnClickSubscription.cancel();
    });
  }
}

class TagView extends BaseView {
  DivElement _tagElement;
  SpanElement _tagText;
  Function onTagChangedCallback;

  TagView(String tag, model.TagStyle tagStyle, this.onTagChangedCallback, [bool isEditableTag = false]) {
    _tagElement = _createTag(tag, tagStyle, isEditableTag);
  }

  DivElement get renderElement => _tagElement;

  DivElement _createTag(String tag, model.TagStyle tagStyle, bool isEditableTag) {
    var tagElement = new DivElement()
      ..classes.add('tag')
      ..dataset['id'] = tag.isEmpty ? 'id-123' : tag;

    switch (tagStyle) {
      case model.TagStyle.Important:
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
              onTagChangedCallback(tag, tag, tagStyle, controller.TagOperation.REMOVE);
              return;
            }
            onTagChangedCallback(tag, tagStyle, controller.TagOperation.REMOVE);
          })
      );

    if (isEditableTag) {
      _tagText.contentEditable = 'true';
      _tagText.onBlur.listen((event) => onTagChangedCallback(tag, (event.target as Element).text, tagStyle, controller.TagOperation.UPDATE));
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
  Function(int, int, String) onUpdateResponseCallback;

  ResponseView(int rowIndex, int colIndex, String response, this.onUpdateResponseCallback) {
    _responseElement = new ParagraphElement()
          ..classes.add('conversation-response__language')
          ..text = response != null ? response : ''
          ..contentEditable = 'true'
          ..dataset['index'] = '$colIndex'
          ..onBlur.listen((event) => onUpdateResponseCallback(rowIndex, colIndex, (event.target as Element).text));
  }

  Element get renderElement => _responseElement;
}

class ResponseListView extends BaseView {
  DivElement _responsesContainer;
  Function onAddNewResponseCallback;
  Function(int, int, String) onUpdateResponseCallback;
  Function(int, bool) onReviewResponseCallback;
  Function(int) onRemoveResponseCallback;

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
      ..dataset['index'] = '$rowIndex'
      ..append(
        new ButtonElement()
          ..classes.add('button-remove-conversation-responses')
          ..text = 'x'
          ..onClick.listen((_) => onRemoveResponseCallback(rowIndex))
      );
    for (int i = 0; i < response['messages'].length; i++) {
      responseEntry.append(new ResponseView(rowIndex, i, response['messages'][i], onUpdateResponseCallback).renderElement);
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

enum FormGroupTypes {
  TEXT,
  CHECKBOX,
  DATE
}

class ProjectConfigurationView extends BaseView{
  DivElement configurationViewElement;
  FormElement _projectConfigurationForm;

  ProjectConfigurationView() {
    configurationViewElement = new DivElement()
      ..classes.add('project-configuration');
    _projectConfigurationForm = new FormElement()
      ..classes.add('configuration-form');
    _buildForm();
    configurationViewElement.append(_projectConfigurationForm);
  }

  DivElement get renderElement => configurationViewElement;

  void _buildForm() {
    _projectConfigurationForm
      ..append(
        _multipleFormGroup('Project Languages:',
          {'English': {'send': FormGroupTypes.CHECKBOX, 'receive': FormGroupTypes.CHECKBOX },
            'Somali': {'send': FormGroupTypes.CHECKBOX, 'receive': FormGroupTypes.CHECKBOX }})
      )
      ..append(
        _singleFormGroup('Automated translations enabled', FormGroupTypes.CHECKBOX)
      )
      ..append(
        _singleFormGroup('Coda dataset regex', FormGroupTypes.TEXT)
      )
      ..append(
        _singleFormGroup('Rapidpro token', FormGroupTypes.TEXT)
      )
      ..append(
        _singleFormGroup('Project start date', FormGroupTypes.DATE)
      )
      ..append(
        _multipleFormGroup('User Configuration:',
          {'person1@africasvoices.org:':
            {'can see messages': FormGroupTypes.CHECKBOX,
              'can perform translations': FormGroupTypes.CHECKBOX,
              'can send messages': FormGroupTypes.CHECKBOX,
              'can send custom messages': FormGroupTypes.CHECKBOX,
              'can approve actions': FormGroupTypes.CHECKBOX,
              'can configure the project': FormGroupTypes.CHECKBOX
            },
          'person2@africasvoices.org:':
            {'can see messages': FormGroupTypes.CHECKBOX,
              'can perform translations': FormGroupTypes.CHECKBOX,
              'can send messages': FormGroupTypes.CHECKBOX,
              'can send custom messages': FormGroupTypes.CHECKBOX,
              'can approve actions': FormGroupTypes.CHECKBOX,
              'can configure the project': FormGroupTypes.CHECKBOX
            },
          'person3@africasvoices.org:':
            {'can see messages': FormGroupTypes.CHECKBOX,
              'can perform translations': FormGroupTypes.CHECKBOX,
              'can send messages': FormGroupTypes.CHECKBOX,
              'can send custom messages': FormGroupTypes.CHECKBOX,
              'can approve actions': FormGroupTypes.CHECKBOX,
              'can configure the project': FormGroupTypes.CHECKBOX
            },
          'person4@africasvoices.org:':
            {'can see messages': FormGroupTypes.CHECKBOX,
              'can perform translations': FormGroupTypes.CHECKBOX,
              'can send messages': FormGroupTypes.CHECKBOX,
              'can send custom messages': FormGroupTypes.CHECKBOX,
              'can approve actions': FormGroupTypes.CHECKBOX,
              'can configure the project': FormGroupTypes.CHECKBOX
            }
          })
      );
  }

  DivElement _singleFormGroup(String label, FormGroupTypes formGroupType) {
    var formGroup = new DivElement()
      ..classes.add('single-form-group');
    var labelElement = new LabelElement()
      ..classes.add('single-form-group__label')
      ..text = label;
    var formElement = new InputElement()
      ..classes.add('single-form-group__input')
      ..type = formGroupType.toString().split('.').last;
    if (formGroupType == FormGroupTypes.CHECKBOX) {
      formGroup
      ..append(formElement)
      ..append(labelElement);
    } else {
      formElement.classes.add('single-form-group__input--is-text');
      formGroup
      ..append(labelElement)
      ..append(formElement);
    }
    return formGroup;
  }

  DivElement _multipleFormGroup(String groupLabel, Map<String, Map<String, FormGroupTypes>> groupElements) {
    var formGroup = new DivElement()
      ..classes.add('multi-form-group');
    var formGroupLabel = new LabelElement()
      ..classes.add('multi-form-group__label')
      ..text = groupLabel;
    formGroup.append(formGroupLabel);
    groupElements.forEach((label, elementGroups) {
      var formElementGroups = new DivElement()
        ..classes.add('multi-form-group-elements');
      var elementGroupLabel = new LabelElement()
        ..classes.add('multi-form-group-elements__label')
        ..text = label;
      formElementGroups.append(elementGroupLabel);
      elementGroups.forEach((label, formGroupType) {
        var formElementGroup = _singleFormGroup(label, formGroupType)
          ..classes.add('single-form-group--in-multi');
        formElementGroups.append(formElementGroup);
      });
      formGroup.append(formElementGroups);
    });
    return formGroup;
  }
}
