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
  BatchRepliesConfigurationView(model.Configuration data) : super() {
    _buildContentPartial(data);
  }

  void _buildContentPartial(model.Configuration data) {
    List<TagView> hasAllTags = [];
    data.hasAllTags.forEach((tag, tagStyle) {
      hasAllTags.add(new TagView(tag, tagStyle, controller.hasAllTagsChanged));
    });
    hasAllTagsContainer = new TagListView(hasAllTags, data.tags, controller.hasAllTagsChanged).renderElement;

    List<TagView> containsLastInTurnTags = [];
    data.containsLastInTurnTags.forEach((tag, tagStyle) {
      containsLastInTurnTags.add(new TagView(tag, tagStyle, controller.containsLastInTurnTagsChanged));
    });
    containsLastInTurnTagsContainer = new TagListView(containsLastInTurnTags, data.tags, controller.containsLastInTurnTagsChanged).renderElement;

    List<TagView> hasNoneTags = [];
    data.hasNoneTags.forEach((tag, tagStyle) {
      hasNoneTags.add(new TagView(tag, tagStyle, controller.hasNoneTagsChanged));
    });
    hasNoneTagsContainer = new TagListView(hasNoneTags, data.tags, controller.hasNoneTagsChanged).renderElement;

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
    addsTagsContainer = new TagListView(addsTags, data.tags, controller.addsTagsChanged, true).renderElement;

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

  TagListView(this.tagElements, Map<String, model.TagStyle> tagList, this.onTagChangedCallback, [bool tagsEditable = false]) {
    _tagsContainer = new DivElement()
      ..classes.add('tags');
    _tagsActionContainer = new SpanElement()
      ..classes.add('tags__actions')
      ..append(
        new ButtonElement()
          ..classes.add('button-add-tag')
          ..text = '+'
          ..onClick.listen((event) {
            if (tagsEditable) {
              _tagsActionContainer.insertAdjacentElement('beforebegin', new TagView('', model.TagStyle.Normal, onTagChangedCallback, tagsEditable).renderElement);
            } else {
              _addTagDropdown(tagList, onTagChangedCallback);
            }
            event.stopPropagation();
          })
      );
    _tagsContainer.append(_tagsActionContainer);
    tagElements.forEach((tag) {
      _tagsActionContainer.insertAdjacentElement('beforebegin', tag.renderElement);
    });
  }

  DivElement get renderElement => _tagsContainer;

  void _addTagDropdown(Map<String, model.TagStyle> tags, Function(String, model.TagStyle) onTagChangedCallback) {
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
            onTagChangedCallback(tag, tags[tag]);
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

    var tagText = new SpanElement()
      ..classes.add('tag__name')
      ..text = tag
      ..title = tag;

    tagElement
      ..append(tagText)
      ..append(
        new SpanElement()
          ..classes.add('tag__remove-btn')
          ..text = 'x'
          ..onClick.listen((_) {
            if (isEditableTag) {
              onTagChangedCallback(tag, tag, tagStyle);
            } else {
              onTagChangedCallback(tag, tagStyle);
            }
          })
      );

    if (isEditableTag) {
      tagText.contentEditable = 'true';
      tagText.focus(); // HACK: this is looking a bit odd - if the user moves the cursor at the end of the text box
                      // then the cursor jumps over the x. Needs investigating and fixing.
      tagText.onBlur.listen((event) => onTagChangedCallback((event.target as Element).text, tag, tagStyle));
    }

    return tagElement;
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
