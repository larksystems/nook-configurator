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
    packageConfiguratorViewElement.onClick.listen((_) {
      document.querySelectorAll('.add-tag-dropdown').forEach((dropdown) => dropdown.remove());
    });
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
    hasAllTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.hasAllTags) {
      hasAllTagsContainer.append(new TagView(tag, tag, TagStyle.Normal).renderElement);
      model.tags.removeWhere((t) => t == tag); // TODO: call controller.command()
    }
    hasAllTagsContainer.append(_addTagAction(model.tags));

    containsLastInTurnTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.containsLastInTurnTags) {
      containsLastInTurnTagsContainer.append(new TagView(tag, tag, TagStyle.Normal).renderElement);
      model.tags.removeWhere((t) => t == tag); // TODO: call controller.command()
    }
    containsLastInTurnTagsContainer.append(_addTagAction(model.tags));

    hasNoneTagsContainer = new DivElement()
      ..classes.add('tags');
    for (var tag in data.hasNoneTags) {
      hasNoneTagsContainer.append(new TagView(tag, tag, TagStyle.Normal).renderElement);
      model.tags.removeWhere((tg) => tg == tag); // TODO: call controller.command()
    }
    hasNoneTagsContainer.append(_addTagAction(model.tags));


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
    for (var suggestedResponse in data.suggestedReplies) {
      suggestedRepliesContainer.append(_addSuggestedResponseEntry(suggestedResponse));
    }

    suggestedRepliesContainer.append(
      new ButtonElement()
        ..classes.add('button-add-conversation-responses')
        ..text = '+'
        ..onClick.listen((event) => (event.target as Element).insertAdjacentElement('beforebegin', _addSuggestedResponseEntry()))
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
      var tagView = new TagView(tag, tag, TagStyle.Normal);
      tagView.editable = true;
      addsTagsContainer.append(tagView.renderElement);
    }
    addsTagsContainer.append(
      new ButtonElement()
        ..classes.add('button-add-tag')
        ..text = '+'
        ..onClick.listen((event) => _createNewTag(event))
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

  SpanElement _addTagAction(List<String> tags) {
    return new SpanElement()
      ..classes.add('tags__actions')
      ..append(
        new ButtonElement()
          ..classes.add('button-add-tag')
          ..text = '+'
          ..onClick.listen((event) {
            _addTagDropdown(event, model.tags);
            event.stopPropagation();
          })
      );
  }

  void _addTagDropdown(MouseEvent event, List<String> tags) {
    var tagActions = (event.target as Element).parent;
    var tagsList = tagActions.parent;
    document.querySelectorAll('.add-tag-dropdown').forEach((dropdown) => dropdown.remove());
    var tagListDropdown = new Element.ul()
      ..classes.add('add-tag-dropdown');
    tagActions.append(tagListDropdown);
    for (var tag in tags) {
      tagListDropdown.append(
        new Element.li()
          ..classes.add('add-tag-dropdown__item')
          ..text = tag
          ..onClick.listen((event) => _addTag((event.target as Element).text, tagsList))
      );
    }
    if (tagListDropdown.children.isEmpty) {
      tagListDropdown.append(
        new Element.li()
          ..classes.add('add-tag-dropdown__item')
          ..text = '--None--'
      );
    }
  }

  void _createNewTag(MouseEvent event) {
    var tagsList = (event.target as Element).parent;
    var newTagView = new TagView('', 'id-123', TagStyle.Normal);
    tagsList.children.last.insertAdjacentElement('beforebegin', newTagView.renderElement);
    newTagView.editable = true;
    newTagView.focus();
  }

  void _addTag(String tag, Element tagList) {
    // TODO: call controller.command()
    tagList.lastChild.lastChild.remove();
    tagList.children.last.insertAdjacentElement('beforebegin', new TagView(tag, tag, TagStyle.Normal).renderElement);
    model.tags.removeWhere((tg) => tg == tag);
  }

  DivElement _addSuggestedResponseEntry([Map suggestedResponse]) {
    return new DivElement()
      ..classes.add('conversation-response')
      ..append(
        new ButtonElement()
          ..classes.add('button-remove-conversation-responses')
          ..text = 'x'
          ..onClick.listen((event) => (event.target as Element).parent.remove()) // TODO: call controller.command
      )
      ..append(
        new ParagraphElement()
          ..classes.add('conversation-response__language')
          ..text = suggestedResponse != null ? suggestedResponse['messages'][0] : ''
          ..contentEditable = 'true'
      )
      ..append(
        new ParagraphElement()
          ..classes.add('conversation-response__language')
          ..text = suggestedResponse != null ? suggestedResponse['messages'][1] : ''
          ..contentEditable = 'true'
      )
      ..append(
        DivElement()
          ..classes.add('conversation-response__reviewed')
          ..append(
            new CheckboxInputElement()
                ..classes.add('conversation-response__reviewed-state')
                ..checked = suggestedResponse != null ? suggestedResponse['reviewed'] : false
                ..onClick.listen((event) => _reviewSuggestedReplies(event))
          )
          ..append(
            new ParagraphElement()
            ..classes.add('conversation-response__reviewed-description')
            ..text = suggestedResponse != null ? '${suggestedResponse['reviewed-by']}, ${suggestedResponse['reviewed-date']}' : ','
          )
      );
  }

  void _reviewSuggestedReplies(MouseEvent event) {
    // TODO: call controller.command()
    var reviewCheckbox = (event.target as CheckboxInputElement);
    var reviewDescription = reviewCheckbox.nextElementSibling;
    if (reviewCheckbox.checked) {
      var reviewedBy = controller.signedInUser.userEmail;
      var now = DateTime.now().toLocal();
      var reviewedDate = '${now.year}-${now.month}-${now.day}';
      reviewDescription.text = '${reviewedBy}, ${reviewedDate}';
    } else {
      reviewDescription.text = ',';
    }
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

  TagView(String text, String tagId, TagStyle tagStyle) {
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
      ..title = text;
    tag.append(_tagText);

    _removeButton = new SpanElement()
      ..classes.add('tag__remove-btn')
      ..text = 'x'
      ..onClick.listen((event) {
        tag.remove();
        // TODO: call controller.command()
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
