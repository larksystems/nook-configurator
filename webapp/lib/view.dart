import 'dart:html';

import 'model.dart' as model;
import 'new_model.dart' as new_model;


import 'logger.dart';
import 'controller.dart' as controller;

import 'platform.dart' as platform;



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
  ButtonElement _backBtn;
  AnchorElement _allProjectsLink;

  NavView() {
    navViewElement = new DivElement()
      ..classes.add('nav');
    _appLogos = new DivElement()
      ..classes.add('nav__app-logo')
      ..append(new ImageElement(src: 'assets/africas-voices-logo.svg'));
    _backBtn = new ButtonElement()
      ..classes.add('nav-links__back-btn')
      ..text = '< Back'
      ..onClick.listen((_) => window.history.back());
    _allProjectsLink = new AnchorElement()
      ..classes.add('nav-links__all-projects-link')
      ..href = '#/project-selector'
      ..text = 'All projects';
    _navLinks = new DivElement()
      ..classes.add('nav-links');
      // ..append(_backBtn)
      // ..append(_allProjectsLink);
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

  Element get backBtn => _backBtn;

  Element get allProjectsLink => _allProjectsLink;

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

class PackageConfiguratorView extends BaseView {
  DivElement packageConfiguratorViewElement;
  DivElement _packageConfiguratorContent;
  model.Configuration configurationData;

  PackageConfiguratorView(this.configurationData) {
    packageConfiguratorViewElement = new DivElement()
      ..classes.add('configure-package-view');
    _packageConfiguratorContent = new DivElement()
      ..classes.add('configure-package-content');
    _buildContentPartial();
    packageConfiguratorViewElement.append(_packageConfiguratorContent);
  }

  DivElement get renderElement => packageConfiguratorViewElement;

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



    var suggestedRepliesView =
      new ResponseListView(configurationData.suggestedReplies, controller.addNewResponse, controller.updateResponse, controller.reviewResponse, controller.removeResponse);

    var suggestedRepliesContainer = suggestedRepliesView.renderElement;

    _packageConfiguratorContent
      ..append(
        new DivElement()
          ..classes.add('configure-package-responses')
          ..append(
            new DivElement()
              ..classes.add('configure-package-responses-headers')
              ..append(
                new HeadingElement.h3()
                  ..text = 'What do you want to say?'
              )
          )
          ..append(suggestedRepliesContainer)
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

  ResponseListView(List<new_model.SuggestedReply> suggestedReplies, this.onAddNewResponseCallback, this.onUpdateResponseCallback, this.onReviewResponseCallback, this.onRemoveResponseCallback) {
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

  DivElement _createResponseEntry(int rowIndex, [new_model.SuggestedReply response]) {
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

      responseEntry.append(
        new ResponseView(rowIndex, 0, response.text, 1, onUpdateResponseCallback).renderElement);

      responseEntry.append(
        new ResponseView(rowIndex, 1, response.translation, 1, onUpdateResponseCallback).renderElement);

    // for (int i = 0; i < response ['messages'].length; i++) {
      // int responseCount = response['messages'][i] == null ? 0 : response['messages'][i].split('').length;
      // responseEntry.append(new ResponseView(rowIndex, i, response['messages'][i], responseCount, onUpdateResponseCallback).renderElement);
    // }
    responseEntry.append(
      DivElement()
        ..classes.add('conversation-response__reviewed')
        ..append(
          new CheckboxInputElement()
              ..classes.add('conversation-response__reviewed-state')
              ..checked = false
              ..onClick.listen((event) => onReviewResponseCallback(rowIndex, (event.target as CheckboxInputElement).checked))
        )
        ..append(
          new ParagraphElement()
            ..classes.add('conversation-response__reviewed-description')
            ..text = ''//response != null ? '${response['reviewed-by']}, ${response['reviewed-date']}' : ''
        )
    );
//=======
//    for (int i = 0; i < response['messages'].length; i++) {
//      int responseCount = response['messages'][i] == null ? 0 : response['messages'][i].split('').length;
//      responseEntry.append(new ResponseView(rowIndex, i, response['messages'][i], responseCount, onUpdateResponseCallback).renderElement);
//    }
//>>>>>>> master-prod
    return responseEntry;
  }
}
