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
    var suggestedRepliesContainer =
      new SuggestedRepliesView(configurationData.suggestedReplies, controller.addNewSuggestedReply, controller.updateSuggestedReply, controller.reviewSuggestedReply, controller.removeSuggestedReply).renderElement;

    _packageConfiguratorContent
      ..append(
        new DivElement()
          ..classes.add('configure-package-suggested-replies')
          ..append(
            new DivElement()
              ..classes.add('configure-package-suggested-replies-headers')
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

class SuggestedReplyView {
  Element _suggestedReplyElement;
  Function onUpdateSuggestedReplyCallback;

  SuggestedReplyView(int rowIndex, int colIndex, String suggestedReply, int suggestedReplyCount, this.onUpdateSuggestedReplyCallback) {
    var suggestedReplyCounter = new SpanElement()
      ..classes.add('conversation-suggested-reply-language__text-count')
      ..classes.toggle('conversation-suggested-reply-language__text-count--alert', suggestedReplyCount > 160)
      ..text = '${suggestedReplyCount}/160';
    var suggestedReplyText =  new ParagraphElement();
    suggestedReplyText
      ..classes.add('conversation-suggested-reply-language__text')
      ..classes.toggle('conversation-suggested-reply-language__text--alert', suggestedReplyCount > 160)
      ..text = suggestedReply != null ? suggestedReply : ''
      ..contentEditable = 'true'
      ..dataset['index'] = '$colIndex'
      ..onBlur.listen((event) => onUpdateSuggestedReplyCallback(rowIndex, colIndex, (event.target as Element).text))
      ..onInput.listen((event) {
        int count = suggestedReplyText.text.split('').length;
        suggestedReplyCounter.text = '${count}/160';
        suggestedReplyText.classes.toggle('conversation-suggested-reply-language__text--alert', count > 160);
        suggestedReplyCounter.classes.toggle('conversation-suggested-reply-language__text-count--alert', count > 160);
      });
    _suggestedReplyElement = new DivElement()
      ..classes.add('conversation-suggested-reply-language')
      ..append(suggestedReplyText)
      ..append(suggestedReplyCounter);
  }
    Element get renderElement => _suggestedReplyElement;
}

class SuggestedRepliesView extends BaseView {
  DivElement _suggestedRepliesContainer;
  Function onAddNewSuggestedReplyCallback;
  Function onUpdateSuggestedReplyCallback;
  Function onReviewSuggestedReplyCallback;
  Function onRemoveSuggestedReplyCallback;

  SuggestedRepliesView(List<Map> suggestedReplies, this.onAddNewSuggestedReplyCallback, this.onUpdateSuggestedReplyCallback, this.onReviewSuggestedReplyCallback, this.onRemoveSuggestedReplyCallback) {
    _suggestedRepliesContainer = new DivElement()
      ..classes.add('conversation-suggested-replies');
    for (int i = 0; i < suggestedReplies.length; i++) {
      _suggestedRepliesContainer.append(_createSuggestedReplyEntry(i, suggestedReplies[i]));
    }
    _suggestedRepliesContainer.append(
      new ButtonElement()
        ..classes.add('button-add-conversation-suggested-replies')
        ..text = '+'
        ..onClick.listen((event) => onAddNewSuggestedReplyCallback())
    );
  }

  DivElement get renderElement => _suggestedRepliesContainer;

  DivElement _createSuggestedReplyEntry(int rowIndex, [Map suggestedReply]) {
    var suggestedReplyEntry = new DivElement()
      ..classes.add('conversation-suggested-reply')
      ..dataset['index'] = '$rowIndex';
    suggestedReplyEntry.append(
        new ButtonElement()
          ..classes.add('button-remove-conversation-suggested-replies')
          ..text = 'x'
          ..onClick.listen((_) {
            var removeSuggestedRepliesModal = new DivElement()
              ..classes.add('remove-conversation-suggested-replies-modal');
            removeSuggestedRepliesModal
              ..append(
                new ParagraphElement()
                  ..classes.add('remove-conversation-suggested-replies-modal__message')
                  ..text = 'Are you sure?'
              )
              ..append(
                new DivElement()
                  ..classes.add('remove-conversation-suggested-replies-modal-actions')
                  ..append(
                    new ButtonElement()
                      ..classes.add('remove-conversation-suggested-replies-modal-actions__action')
                      ..text = 'Yes'
                      ..onClick.listen((_) => onRemoveSuggestedReplyCallback(rowIndex))
                  )
                  ..append(
                    new ButtonElement()
                      ..classes.add('remove-conversation-suggested-replies-modal-actions__action')
                      ..text = 'No'
                      ..onClick.listen((_) => removeSuggestedRepliesModal.remove())
                  )
              );
            suggestedReplyEntry.append(removeSuggestedRepliesModal);
          })
      );
    for (int i = 0; i < suggestedReply['messages'].length; i++) {
      int suggestedReplyCount = suggestedReply['messages'][i] == null ? 0 : suggestedReply['messages'][i].split('').length;
      suggestedReplyEntry.append(new SuggestedReplyView(rowIndex, i, suggestedReply['messages'][i], suggestedReplyCount, onUpdateSuggestedReplyCallback).renderElement);
    }
    return suggestedReplyEntry;
  }
}
