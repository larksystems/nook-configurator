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
  AuthHeaderViewPartial authHeaderViewPartial;


  NavView() {
    navViewElement = new DivElement()
      ..classes.add('nav');
    _appLogos = new DivElement()
      ..classes.add('nav__app-logo')
      ..append(new ImageElement(src: 'assets/africas-voices-logo.svg'));
    _projectTitle = new DivElement()
      ..classes.add('nav__project-title');
    authHeaderViewPartial = new AuthHeaderViewPartial();

    navViewElement.append(_appLogos);
    navViewElement.append(_projectTitle);
    navViewElement.append(authHeaderViewPartial.authElement);
  }

  void set projectTitle(String projectName) => _projectTitle.text = projectName;
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

class DashboardView extends BaseView {
  List<ActivePackagesViewPartial> activePackages;
  List<AvailablePackagesViewPartial> availablepackages;

  DivElement dashboardViewElement;
  DivElement _projectActionsContainer;
  AnchorElement _conversationsLink;
  AnchorElement _oversightDashboardLink;
  DivElement activePackagesContainer;
  DivElement availablePackagesContainer;

  DashboardView() {
    activePackages = [];
    availablepackages = [];
    dashboardViewElement = new DivElement()..classes.add('dashboard');
    _projectActionsContainer = new DivElement()
      ..classes.add('dashboard__project-actions');
    _conversationsLink = new AnchorElement()
      ..classes.add('dashboard__project-actions-link')
      ..text = "Go to conversations"
      ..href = "#";
    _oversightDashboardLink = new AnchorElement()
      ..classes.add('dashboard__project-actions-link')
      ..text = "Go to oversight dashboard"
      ..href = "#";
    activePackagesContainer = new DivElement()
      ..classes.add('active-packages');
    availablePackagesContainer = new DivElement()
      ..classes.add('available-packages');

    _projectActionsContainer.append(_conversationsLink);
    _projectActionsContainer.append(_oversightDashboardLink);
    dashboardViewElement.append(_projectActionsContainer);
    dashboardViewElement.append(activePackagesContainer);
    dashboardViewElement.append(availablePackagesContainer);
  }

  DivElement get renderElement => dashboardViewElement;

  void renderActivePackages() {
    activePackagesContainer.children.clear();
    activePackagesContainer.append(new HeadingElement.h1()..text = "Active packages");
    if (activePackages.isNotEmpty) {
      activePackages.forEach((package) => activePackagesContainer.append(package.packageElement));
    }
  }

  void renderAvailablePackages() {
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

  ActivePackagesViewPartial(String packageName, String conversationsLink, String configurationLink) {
    packageElement = new DivElement()
      ..classes.add('active-packages__package');
    _packageName = new HeadingElement.h4()
      ..text = '$packageName (Active)';
    _packageActionsContainer = new DivElement()
      ..classes.add('active-packages__package-actions');
    _dashboardAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Dashboard'
      ..href = '#/dashboard';
    _conversationsAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Conversations'
      ..href = conversationsLink;
    _configureAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Configure'
      ..href = configurationLink;
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
  model.Configuration data;
  List<String> tags;
  BatchRepliesConfigurationView(this.data, this.tags) : super() {
    _buildContentPartial();
  }

  void _buildContentPartial() {
    hasAllTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.hasAllTags) {
      hasAllTagsContainer.append(new TagView(tag, tag, TagStyle.Normal, controller.TagType.HAS_ALL_TAGS, data, tags).renderElement);
    }
    hasAllTagsContainer.append(_addTagAction(controller.TagType.HAS_ALL_TAGS));

    containsLastInTurnTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.containsLastInTurnTags) {
      containsLastInTurnTagsContainer.append(new TagView(tag, tag, TagStyle.Normal, controller.TagType.CONTAINS_LAST_IN_TURN_TAGS, data, tags).renderElement);
    }
    containsLastInTurnTagsContainer.append(_addTagAction(controller.TagType.CONTAINS_LAST_IN_TURN_TAGS));

    hasNoneTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.hasNoneTags) {
      hasNoneTagsContainer.append(new TagView(tag, tag, TagStyle.Normal, controller.TagType.HAS_NONE_TAGS, data, tags).renderElement);
    }
    hasNoneTagsContainer.append(_addTagAction(controller.TagType.HAS_NONE_TAGS));


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

    suggestedRepliesContainer = new DivElement()
      ..classes.add('conversation-responses');
    for (int i = 0; i < data.suggestedReplies.length; i++) {
      suggestedRepliesContainer.append(_addSuggestedResponseEntry(i));
    }

    suggestedRepliesContainer.append(
      new ButtonElement()
        ..classes.add('button-add-conversation-responses')
        ..text = '+'
        ..onClick.listen((event) => controller.command(controller.UIAction.updateBatchRepliesPackageResponses, null))
    );

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


    addsTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.addsTags) {
      var tagView = new TagView(tag, tag, TagStyle.Normal, controller.TagType.ADDS_TAGS, data, tags);
      tagView.editable = true;
      addsTagsContainer.append(tagView.renderElement);
    }
    addsTagsContainer.append(
      new ButtonElement()
        ..classes.add('button-add-tag')
        ..text = '+'
        ..onClick.listen((event) => _createNewTag((event.target as Element).parent, controller.TagType.ADDS_TAGS, data, tags))
    );
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

  SpanElement _addTagAction(controller.TagType tagType) {
    return new SpanElement()
      ..classes.add('tags__actions')
      ..append(
        new ButtonElement()
          ..classes.add('button-add-tag')
          ..text = '+'
          ..onClick.listen((event) {
            var tagActions = (event.target as Element).parent;
            _addTagDropdown(tagActions, tagType);
            event.stopPropagation();
          })
      );
  }

  void _addTagDropdown(Element tagActionsContainer, controller.TagType tagType) {
    document.querySelectorAll('.add-tag-dropdown').forEach((dropdown) => dropdown.remove());
    var tagListDropdown = new Element.ul()
      ..classes.add('add-tag-dropdown');
    tagActionsContainer.append(tagListDropdown);
    var tagsToShow = tags.isEmpty ? ['--None--'] : tags;
    for (var tag in tagsToShow) {
      tagListDropdown.append(
        new Element.li()
          ..classes.add('add-tag-dropdown__item')
          ..text = tag
          ..onClick.listen((_) {
            if (tag != '--None--') _addTag(tag, tagType);
          })
      );
    }
    var documentOnClickSubscription;
    documentOnClickSubscription = document.onClick.listen((event) {
      event.stopPropagation();
      tagListDropdown.remove();
     documentOnClickSubscription.cancel();
    });
  }

  void _createNewTag(Element tagsList, controller.TagType tagType, model.Configuration data, List<String> tags) {
    var newTagView = new TagView('', 'id-123', TagStyle.Normal, tagType, data, tags);
    tagsList.children.last.insertAdjacentElement('beforebegin', newTagView.renderElement);
    newTagView.editable = true;
    newTagView.focus();
  }

  void _addTag(String tag, controller.TagType tagType) {
    switch(tagType) {
      case controller.TagType.HAS_ALL_TAGS:
        data.hasAllTags.add(tag);
        break;
      case controller.TagType.CONTAINS_LAST_IN_TURN_TAGS:
        data.containsLastInTurnTags.add(tag);
        break;
      case controller.TagType.HAS_NONE_TAGS:
        data.hasNoneTags.add(tag);
        break;
      case controller.TagType.ADDS_TAGS:
        data.addsTags.add(tag);
        break;
    }
    tags.removeWhere((t) => t == tag);
    controller.command(controller.UIAction.updateBatchRepliesPackageTags,
      new controller.BatchRepliesPackageTagData()
        ..tags = tags
        ..hasAllTags = data.hasAllTags
        ..containsLastInTurnTags = data.containsLastInTurnTags
        ..hasNoneTags = data.hasNoneTags
        ..addsTags = data.addsTags);
  }

  DivElement _addSuggestedResponseEntry(int index) {
    var responseEntry = new DivElement()
      ..classes.add('conversation-response')
      ..append(
        new ButtonElement()
          ..classes.add('button-remove-conversation-responses')
          ..text = 'x'
          ..onClick.listen((event) {
            data.suggestedReplies.removeAt(index);
            controller.command(controller.UIAction.updateBatchRepliesPackageResponses,
              new controller.BatchRepliesPackageResponseData()
                ..messages = data.suggestedReplies
            );
          })
      );

    for (int i = 0; i < data.suggestedReplies[index]['messages'].length; i++) {
      responseEntry.append(
        new ParagraphElement()
          ..classes.add('conversation-response__language')
          ..text = data.suggestedReplies[index]['messages'][i]
          ..contentEditable = 'true'
          ..onBlur.listen((event) {
            data.suggestedReplies[index]['messages'][i] = (event.target as Element).text;
            controller.command(controller.UIAction.updateBatchRepliesPackageResponses,
              new controller.BatchRepliesPackageResponseData()
                ..messages = data.suggestedReplies
            );
          })
      );
    }

    responseEntry.append(
      DivElement()
        ..classes.add('conversation-response__reviewed')
        ..append(
          new CheckboxInputElement()
              ..classes.add('conversation-response__reviewed-state')
              ..checked = data.suggestedReplies[index]['reviewed']
              ..onClick.listen((event) {
                data.suggestedReplies[index]['reviewed'] = (event.target as CheckboxInputElement).checked;
                if (data.suggestedReplies[index]['reviewed']) {
                  data.suggestedReplies[index]['reviewed-by'] = controller.signedInUser.userEmail;
                  var now = DateTime.now().toUtc();
                  var reviewedDate = '${now.year}-${now.month}-${now.day}';
                  data.suggestedReplies[index]['reviewed-date'] = reviewedDate;
                } else {
                  data.suggestedReplies[index]['reviewed-by'] = '';
                  data.suggestedReplies[index]['reviewed-date'] = '';
                }
                controller.command(controller.UIAction.updateBatchRepliesPackageResponses,
                  new controller.BatchRepliesPackageResponseData()
                    ..messages = data.suggestedReplies
                  );
              })
        )
        ..append(
          new ParagraphElement()
          ..classes.add('conversation-response__reviewed-description')
          ..text = '${data.suggestedReplies[index]['reviewed-by']}, ${data.suggestedReplies[index]['reviewed-date']}'
        )
    );
      return responseEntry;
  }
}

enum TagStyle {
  Normal,
  Important,
}

class TagView extends BaseView {
  DivElement tag;
  SpanElement _tagText;
  SpanElement _removeButton;
  controller.TagType tagType;
  model.Configuration data;
  List<String> tags;

  TagView(String text, String tagId, TagStyle tagStyle, this.tagType, this.data, this.tags) {

    tag = new DivElement()
      ..classes.add('tag')
      ..dataset['id'] = tagId;
    switch (tagStyle) {
      case TagStyle.Important:
        tag.classes.add('tag--important');
        break;
      default:
        break;
    }

    _tagText = new SpanElement()
      ..classes.add('tag__name')
      ..text = text
      ..title = text
      ..onBlur.listen((_) {
          if (tagType == controller.TagType.ADDS_TAGS) {
            var index = data.addsTags.indexOf(tag.getAttribute('data-id'));
            if (index > -1) {
              data.addsTags.removeAt(index);
              data.addsTags.insert(index, _tagText.text);
            } else {
              data.addsTags.add(_tagText.text);
            }
          }
          controller.command(controller.UIAction.updateBatchRepliesPackageTags,
            new controller.BatchRepliesPackageTagData()
              ..tags = tags
              ..hasAllTags = data.hasAllTags
              ..containsLastInTurnTags = data.containsLastInTurnTags
              ..hasNoneTags = data.hasNoneTags
              ..addsTags = data.addsTags);

      });
    tag.append(_tagText);

    _removeButton = new SpanElement()
      ..classes.add('tag__remove-btn')
      ..text = 'x'
      ..onClick.listen((_) {
        switch(tagType) {
          case controller.TagType.HAS_ALL_TAGS:
            data.hasAllTags.removeWhere((t) => t == _tagText.text);
            tags.add(_tagText.text);
            break;
          case controller.TagType.CONTAINS_LAST_IN_TURN_TAGS:
            data.containsLastInTurnTags.removeWhere((t) => t == _tagText.text);
            tags.add(_tagText.text);
            break;
          case controller.TagType.HAS_NONE_TAGS:
            data.hasNoneTags.removeWhere((t) => t == _tagText.text);
            tags.add(_tagText.text);
            break;
          case controller.TagType.ADDS_TAGS:
            data.addsTags.removeWhere((t) => t == _tagText.text);
            break;
        }
        controller.command(controller.UIAction.updateBatchRepliesPackageTags,
          new controller.BatchRepliesPackageTagData()
            ..tags = tags
            ..hasAllTags = data.hasAllTags
            ..containsLastInTurnTags = data.containsLastInTurnTags
            ..hasNoneTags = data.hasNoneTags
            ..addsTags = data.addsTags);
      });

    tag.append(_removeButton);
  }

  DivElement get renderElement => tag;

  // HACK: this is looking a bit odd - if the user moves the cursor at the end of the text box
  // then the cursor jumps over the x. Needs investigating and fixing.
  void set editable(bool value) => _tagText.contentEditable = '$value';

  void focus() {
    _tagText.focus();
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
