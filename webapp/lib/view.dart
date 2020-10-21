import 'dart:convert';
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

class BaseView {
  DivElement get renderElement => new DivElement();
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

class AuthMainView extends BaseView{
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

class DashboardView extends BaseView{
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
  @override
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
      ..href = '#/dashboard';
    _conversationsAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Conversations'
      ..href = '#/conversations';
    _configureAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Configure'
      ..href = '#/batch-replies-configuration';
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

class BatchRepliesConfigurationView extends PackageConfiguratorView {}

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
    _buildContentPartial();
    packageConfiguratorViewElement.append(_packageConfiguratorSidebar);
    packageConfiguratorViewElement.append(_packageConfiguratorContent);
  }

  @override
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

  DivElement _buildContentPartial() {
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
                ..append(
                  new DivElement()
                    ..classes.add('tags')
                    ..append(
                      new ButtonElement()
                        ..classes.add('button-add-tag')
                        ..text = '+'
                        ..onClick.listen(_addTagDropdown)
                    )
                )
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
                ..append(
                  new DivElement()
                    ..classes.add('tags')
                    ..append(
                      new ParagraphElement()
                        ..classes.add('tags__tag')
                        ..text = 'Denial'
                    )
                    ..append(
                      new ParagraphElement()
                        ..classes.add('tags__tag')
                        ..text = 'Rumour'
                    )
                    ..append(
                      new ButtonElement()
                        ..classes.add('button-add-tag')
                        ..text = '+'
                        ..onClick.listen(_addTagDropdown)
                    )
                )
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
                ..append(
                  new DivElement()
                    ..classes.add('tags')
                    ..append(
                      new ParagraphElement()
                        ..classes.add('tags__tag')
                        ..text = 'escalate'
                    )
                    ..append(
                      new ParagraphElement()
                        ..classes.add('tags__tag')
                        ..text = 'stop'
                    )
                    ..append(
                      new ButtonElement()
                        ..classes.add('button-add-tag')
                        ..text = '+'
                        ..onClick.listen(_addTagDropdown)
                    )
                )
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
        ..append(
          new DivElement()
            ..classes.add('conversation-responses')
            ..append(
              new DivElement()
                ..classes.add('conversation-response')
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-response__language')
                    ..text = 'Greetings to you dear listener! Thanks for the beautiful way you are sharing your thoughts with us'
                    ..contentEditable = 'true'
                )
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-response__language')
                    ..text = 'Saalan, quruz badan nage guddoon dhagaystaha sharafta leh, waad ku mahadsantahay sida quruxda badana ee aad noola wadageyso fikradahaada'
                    ..contentEditable = 'true'
                )
                ..append(
                  DivElement()
                    ..classes.add('conversation-response__reviewed')
                    ..append(
                      new CheckboxInputElement()
                          ..classes.add('conversation-response__reviewed-state')
                          ..checked = true
                    )
                    ..append(
                      new ParagraphElement()
                      ..classes.add('conversation-response__reviewed-description')
                      ..text = 'nancy@whatworks.co.ke, 2020-10-10'
                    )
                )
            )
            ..append(
              new DivElement()
                ..classes.add('conversation-response')
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-response__language')
                    ..text = 'Thanks, we hear you and appreciate. We think it is really important to tell you what we know from trusted sources'
                    ..contentEditable = 'true'
                )
                ..append(
                  new ParagraphElement()
                    ..classes.add('conversation-response__language')
                    ..text = 'Mahadsanid, waan ku maqalnaa waanan kuu mahadnaqaynaa. Waxaa muhiim ah inaan kula wadaagno waxaa aan ognahay oo ka yimid ilo lagu kalsoon yahay'
                    ..contentEditable = 'true'
                )
                ..append(
                  DivElement()
                    ..classes.add('conversation-response__reviewed')
                    ..append(
                      new CheckboxInputElement()
                        ..classes.add('conversation-response__reviewed-state')
                    )
                    ..append(
                      new ParagraphElement()
                        ..classes.add('conversation-response__reviewed-description')
                        ..text = 'another@example.org, 2020-10-20'
                    )
                )
            )
        )
    );
    _packageConfiguratorContent.append(
      new DivElement()
        ..classes.add('configure-package-labels')
        ..append(
          new ParagraphElement()
            ..classes.add('conversation-tags__title')
            ..text = 'What new labels would like to tag the message with?'
        )
        ..append(
          new DivElement()
            ..classes.add('tags')
            ..append(
              new ParagraphElement()
                ..classes.add('tags__tag')
                ..text = 'Organic conversation appreciation'
            )
            ..append(
              new ParagraphElement()
                ..classes.add('tags__tag')
                ..text = 'Organic conversation hostility'
            )
            ..append(
              new ParagraphElement()
                ..classes.add('tags__tag')
                ..text = 'RP Substance appreciation'
            )
            ..append(
              new ParagraphElement()
                ..classes.add('tags__tag')
                ..text = 'RP Substance hostility'
            )
            ..append(
              new ButtonElement()
                ..classes.add('button-add-tag')
                ..text = '+'
                ..onClick.listen(_addTagDropdown)
            )
        )
    );
  }

  void _addTagDropdown(MouseEvent event) {
    var tagsList = (event.target as Element).parent;
    if (tagsList.children.last.classes.contains('add-tag-dropdown')) tagsList.lastChild.remove();

    tagsList.append(
      new Element.ul()
        ..classes.add('add-tag-dropdown')
        ..append(
          new Element.li()
            ..classes.add('add-tag-dropdown__item')
            ..text = 'Tag 1'
            ..onClick.listen((event) => _addTag((event.target as Element).text, tagsList))
        )
        ..append(
          new Element.li()
            ..classes.add('add-tag-dropdown__item')
            ..text = 'Tag 2'
            ..onClick.listen((event) => _addTag((event.target as Element).text, tagsList))
        )
        ..append(
          new Element.li()
            ..classes.add('add-tag-dropdown__item')
            ..text = 'Tag 3'
            ..onClick.listen((event) => _addTag((event.target as Element).text, tagsList))
        )
    );
  }

  void _addTag(String tag, Element tagList) {
    tagList.lastChild.remove();
    tagList.children.last.insertAdjacentElement('beforebegin',
      new ParagraphElement()
        ..classes.add('tags__tag')
        ..text = '$tag'
    );
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

  @override
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
